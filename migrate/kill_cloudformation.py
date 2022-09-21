#!/usr/bin/env python3
import argparse
import boto3
import re
import yaml
from botocore.exceptions import ValidationError
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
    child_id = s["PhysicalResourceId"]
    child_name = re.search(r':stack/(.*)/', child_id).group(1)
    if cf.describe_stacks(StackName=child_id)["Stacks"][0]["StackStatus"] == "DELETE_COMPLETE":
        return
    child_resources = cf.describe_stack_resources(StackName=child_name)["StackResources"]
    stacks[child_name] = [r["LogicalResourceId"] for r in child_resources if r["ResourceStatus"] != "DELETE_COMPLETE"]
    for r in child_resources:
        if r["ResourceType"] == "AWS::CloudFormation::Stack":
            get_stack_resources(r)

root_resources = cf.describe_stack_resources(StackName=stack_name)["StackResources"]

stacks = {
    stack_name: [r["LogicalResourceId"] for r in root_resources if r["ResourceStatus"] != "DELETE_COMPLETE"]
}

for s in root_resources:
    if s["ResourceType"] == "AWS::CloudFormation::Stack":
        get_stack_resources(s)

for stack, resources in stacks.items():
    print(f"aws cloudformation delete-stack --stack-name {stack} --retain-resources {' '.join(resources)} --role arn:aws:iam::890728157128:role/cloudformation-only")

print("The role used here has FULL permissions to cloudformation but NO permissions to anything else. Run the delete command WITHOUT any of the retain resources options, but using the role. Then re-run this script, and run the same delete command with all the retain resources commands. After the first run, the stack will be in the delete failed state, with all resources having failed. This opens the gate to retain every resource, so the second run deletes the stack and only the stack. No need to re-upload the cloudformation with a retain policies.")
