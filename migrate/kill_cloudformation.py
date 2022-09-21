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


def get_stack_resources(s) -> dict:
    child_id = re.search(r':stack/(.*)/', s["PhysicalResourceId"]).group(1)
    child_resources = cf.describe_stack_resources(StackName=child_id)["StackResources"]
    stacks[child_id] = [r["LogicalResourceId"] for r in child_resources]
    for r in child_resources:
        if r["ResourceType"] == "AWS::CloudFormation::Stack":
            get_stack_resources(r)

root_resources = cf.describe_stack_resources(StackName=stack_name)["StackResources"]

stacks = {
    "root": [r["LogicalResourceId"] for r in root_resources]
}

for s in root_resources:
    if s["ResourceType"] == "AWS::CloudFormation::Stack":
        get_stack_resources(s)

for stack, resources in stacks.items():
    print(f"aws cloudformation delete-stack {stack} --retain-resources {','.join(resources)}")
