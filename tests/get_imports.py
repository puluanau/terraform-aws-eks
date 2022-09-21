#!/usr/bin/env python3
import argparse
import boto3
import re
import yaml
from pprint import pprint

parser = argparse.ArgumentParser(
    description="terraform eks module importer", formatter_class=argparse.ArgumentDefaultsHelpFormatter
)
parser.add_argument("--print-stack", help="Just prints a stack's resources")
args = parser.parse_args()

region="us-west-2"
stack_name="chibipug25155"

cf = boto3.client("cloudformation", region)

stack_map = {
    "EfsStackNestedStackEfsStackNestedStackResource": "efs_stack",
    "EksStackNestedStackEksStackNestedStackResource": "eks_stack",
    "S3StackNestedStackS3StackNestedStackResource": "s3_stack",
    "VpcStackNestedStackVpcStackNestedStackResource": "vpc_stack",
}


stacks = {
    "root": cf.describe_stack_resources(StackName=stack_name)["StackResources"]
}

for s in stacks["root"]:
    if s["ResourceType"] == "AWS::CloudFormation::Stack":
        for logical_id, name in stack_map.items():
            if s["LogicalResourceId"].startswith(logical_id):
                child_id = re.search(r':stack/(.*)/', s["PhysicalResourceId"]).group(1)
                resources = []
                resources = {
                    r["LogicalResourceId"][:-8]: r["PhysicalResourceId"]
                    for r in cf.describe_stack_resources(StackName=child_id)["StackResources"]
                }
                stacks[name] = {
                    "id": child_id,
                    "resources": resources,
                }
                break
        else:
            raise Exception(f"Nothing to map stack {s} to!")

if args.print_stack:
    pprint(stacks[args.print_stack])
    exit(0)


with open("resource_map.yaml") as f:
    resource_map = yaml.safe_load(f)


def t(val: str) -> str:
    val = re.sub(r'{{region}}', region, val)
    val = re.sub(r'{{stack_name}}', stack_name, val)
    return val

imports = []

for map_stack, items in resource_map.items():
    resources = stacks[map_stack]["resources"]
    for item in items:
        tf_import_path = t(item["tf"])
        if value := item.get("value"):
            resource_id = t(value)
        elif cf_sgr := item.get("cf_sgr"):
            sg = resources[t(cf_sgr["sg"])]
            resource_id = f"{sg}{t(cf_sgr['rule'])}"
        elif cf_igw_attachment := item.get("cf_igw_attachment"):
            igw_id = resources[t(cf_igw_attachment["igw"])]
            vpc_id = resources[t(cf_igw_attachment["vpc"])]
            resource_id = f"{igw_id}:{vpc_id}"
        elif assoc := item.get("cf_rtassoc"):
            resource_id = f"{resources[t(assoc['subnet'])]}/{resources[t(assoc['route_table'])]}"
        else:
            resource_id = resources[t(item["cf"])]
        imports.append(f"terraform import '{tf_import_path}' '{resource_id}'")

print("\n".join(imports))
