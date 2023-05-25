#!/usr/bin/env python3
"""
Title: YAML Validator
Description: Validates a YAML file against a JSON schema.
Author: Javi3Code
Date: Tuesday May 16, 2023
"""

import sys
import json
from jsonspec.validators import load

schema_file = sys.argv[1]
json_str = sys.argv[2]

print("validating...")

with open(schema_file) as f:
    schema = load(json.load(f))

json_data = json.loads(json_str)

try:
    names = [item['name'] for item in json_data['workspaces']]
    shortnames = [item['short-name'] for item in json_data['workspaces']]
    errors=[]
    if len(names) != len(set(names)):
        errors.append("\tError: Workspace.name should be unique")
    if len(shortnames) != len(set(shortnames)):
        errors.append("\tError: Workspace.short-name should be unique")
    if(errors):
        raise Exception('\n'.join(errors))
    print("validating...")
    schema.validate(json_data)
except Exception as e:
    print(f"Yml validation:\n{str(e)}")
    sys.exit(1)
print("OK")
