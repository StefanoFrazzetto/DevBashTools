#!/bin/bash

function _print_aws_profile_required {
   echo "You need to specify the AWS profile."
   echo "E.g. ${FUNCNAME[1]} devops"
}

function _check_aws_profile_exists {
    profile=$1
    res=$(aws configure --profile "$profile" list)
    return $?
}

function aws_load_vars {
    if [ "$#" != 1 ]; then
        _print_aws_profile_required
        return 1
    fi

    unset AWS_ACTIVE_PROFILE
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY

    profile=$1
    # Check the profile exists
    if [[ $(aws configure --profile "$profile" list) && $? != 0 ]]; then
        return 2
    fi

    export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile "$AWS_ACTIVE_PROFILE")
    export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile "$AWS_ACTIVE_PROFILE")

    echo "Exported the following vars:"
    echo "- AWS_ACCESS_KEY_ID=[REDACTED]"
    echo "- AWS_SECRET_ACCESS_KEY=[REDACTED]"
}

function aws_list_access_keys {
    if [ "$#" != 1 ]; then
        _print_aws_profile_required
        return 1
    fi

    profile=$1
    for user in $(aws iam list-users --profile "$profile" --output text | awk '{print $NF}'); do
        aws iam list-access-keys --profile "$profile" --user $user --output text
    done
}

# Get the password of an EC2 instance and use a private key to decrypt it.
function aws_get_instance_password {
    if [ "$#" != 3 ]; then
        echo "You need to specify the AWS profile, EC2 instance ID and the private key to use for decrypting the password."
        echo "E.g. aws_get_instance_password devops i-04e0a046d90d904cd build-agents.pem"
        return 1
    fi

    profile=$1
    instance_id=$2
    private_key=$3

    # Check the profile exists
    if [[ $(aws configure --profile "$profile" list) && $? != 0 ]]; then
        return 1
    fi

    region="$(aws configure get region --profile $profile)"

    if ! test -f "$private_key"; then
        echo "Cannot find the specified private key: $private_key"
        return 2
    fi

    aws ec2 get-password-data --profile "$profile" --region "$region" --instance-id "$instance_id" --priv-launch-key "$private_key" | jq '.PasswordData'
}

function aws_get_instance_private_ip {
    if [ "$#" != 2 ]; then
        echo "You need to specify the AWS profile and the EC2 instance ID."
        echo "E.g. aws_get_instance_password devops i-04e0a046d90d904cd"
        return 1
    fi

    profile=$1
    instance_id=$2

    _check_aws_profile_exists "$profile"
    if [ $? != 0 ]; then
        return $?
    fi

    aws ec2 describe-instances \
    --profile "$profile" \
    --filters "Name=instance-id,Values=$instance_id" \
    --query 'Reservations[*].Instances[*].[PrivateIpAddress]' \
    --output text
}

function aws_rdc {
    if [ "$#" != 3 ]; then
        echo "You need to specify the AWS profile and the EC2 instance ID."
        echo "E.g. aws_get_instance_password devops i-04e0a046d90d904cd"
        return 1
    fi

    profile=$1
    instance_id=$2
    private_key=$3

    instance_ip=$(aws_get_instance_private_ip $profile $instance_id)
    password=$(aws_get_instance_password $profile $instance_id $private_key)

    echo "Instance private IP: $instance_ip"
    echo "Instance password: $password"

    echo "Run the following in PowerShell:"
    echo -e "cmdkey /generic:"$instance_ip" /user:"Administrator" /pass:"$password"; mstsc /v:"$instance_ip" /admin"
    echo "Warning: the instance details will be saved on your machine."
}
