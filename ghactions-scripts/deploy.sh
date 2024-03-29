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