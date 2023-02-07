import boto3
import sys

name_stack=str(sys.argv[1])
print(name_stack)

#Declare Boto3 clients

client = boto3.client('cloudformation', region_name='us-east-1')
waiter_create_complete = client.get_waiter('stack_create_complete')
waiter_update_complete = client.get_waiter('stack_update_complete')

# Python Function to describe Status and wait until it is completed

def main(name_stack):
    
    stack_status_parsed = get_stack_status(f'{name_stack}')

    print(stack_status_parsed)
    
    if stack_status_parsed == "CREATE_IN_PROGRESS":
        print(f"Stack {name_stack} is being created.")
        print(f"Waiting for stack {name_stack} to complete...")
        waiter_create_complete.wait(
        StackName=f'{name_stack}',
        WaiterConfig={
            'Delay': 30,
            'MaxAttempts': 25
            }
        )
    
    elif stack_status_parsed == "UPDATE_IN_PROGRESS" or stack_status_parsed == "UPDATE_COMPLETE_CLEANUP_IN_PROGRESS":
        print(f"Stack {name_stack} is being updated.")
        print(f"Waiting for stack {name_stack} to update...")
        waiter_update_complete.wait(
        StackName=f'{name_stack}',
        WaiterConfig={
            'Delay': 30,
            'MaxAttempts': 25
            }
        )
    
    elif stack_status_parsed == "ROLLBACK_IN_PROGRESS" or stack_status_parsed == "ROLLBACK_COMPLETE":
        sys.exit(f"Stack {name_stack} failed to create.")
    
    else:
        print("Stack does not need to be created or updated")


def get_stack_status(name_stack):
    
    stack_status = client.describe_stacks(
    StackName=f'{name_stack}'
    )
    stack_status_parsed = stack_status['Stacks'][0]['StackStatus']
    #print(stack_status_parsed)
    return stack_status_parsed

main(name_stack)