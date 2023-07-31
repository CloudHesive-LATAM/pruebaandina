#/bin/bash

stack_name="$1"
template_url="$2"

# Use the environment variables directly
echo "Received parameter: InstanceType=${InstanceType}"
echo "Received parameter: Monitoring=${Monitoring}"

# Remove the first two positional parameters (stack_name and template_url)
shift 2

# Process dynamic parameters as key-value pairs
while [[ $# -gt 0 ]]; do
  key="$1"
  value="$2"

  # Validate key and value format
  if [[ "$key" == ParameterKey=* && "$value" == ParameterValue=* ]]; then
    # Extract the parameter name and value without the prefixes
    parameter_key="${key#ParameterKey=}"
    parameter_value="${value#ParameterValue=}"
    
    echo "Received parameter: $parameter_key=$parameter_value"
    # Use the parameter as needed in your script logic...
  else
    echo "Error: Invalid parameter format: $key $value"
    exit 1
  fi

  # Shift the processed key-value pair
  shift 2
done

# Your existing script logic goes here...

if ! update_output=$(aws cloudformation update-stack --stack-name "$stack_name" --template-url "$template_url" --parameters "$parameters" 2>&1); then
  if [[ $update_output == *"No updates are to be performed."* ]]; then
    echo "No updates needed for the stack."
  elif [[ $update_output == *"An error occurred (ValidationError) when calling the UpdateStack operation: Stack ["$stack_name"] does not exist"* ]]; then
    aws cloudformation create-stack --stack-name "$stack_name" --template-url "$template_url" --parameters "$parameters"
    aws cloudformation wait stack-create-complete --stack-name "$stack_name"
  else
    echo "Update failed: $update_output"
    exit 1
  fi
else
  echo "Stack update was executed. Update in progress..."
  aws cloudformation wait stack-update-complete --stack-name "$stack_name"
fi

stack_status=$(aws cloudformation describe-stacks --stack-name "$stack_name" --query "Stacks[0].StackStatus" --output text)
       
if [[ $stack_status != "CREATE_COMPLETE" && $stack_status != "UPDATE_COMPLETE" ]]; then
  echo "Current status: $stack_status"
  exit 1
else
  echo "Current status: $stack_status."
fi