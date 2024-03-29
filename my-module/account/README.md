## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 0.15 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 3.45 |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 3.45 |

## Modules

No modules.

## Resources

| Name                                                                                                                                            | Type        |
| ----------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_iam_account_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_alias)                     | resource    |
| [aws_iam_account_password_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy) | resource    |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                      | data source |

## Inputs

| Name                                                                           | Description                                               | Type                                                                                                                                                                                                                                                                                                                                        | Default                                                                                                                                                                                                                                                                                                                               | Required |
| ------------------------------------------------------------------------------ | --------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_name"></a> [name](#input_name)                                  | The name for the AWS account. Used for the account alias. | `string`                                                                                                                                                                                                                                                                                                                                    | n/a                                                                                                                                                                                                                                                                                                                                   |   yes    |
| <a name="input_password_policy"></a> [password_policy](#input_password_policy) | Password Policy for the AWS account.                      | <pre>object({<br> minimum_password_length = number<br> require_numbers = bool<br> require_symbols = bool<br> require_lowercase_characters = bool<br> require_uppercase_characters = bool<br> allow_users_to_change_password = bool<br> hard_expiry = bool<br> max_password_age = number<br> password_reuse_prevention = number<br> })</pre> | <pre>{<br> "allow_users_to_change_password": true,<br> "hard_expiry": false,<br> "max_password_age": 0,<br> "minimum_password_length": 8,<br> "password_reuse_prevention": 0,<br> "require_lowercase_characters": true,<br> "require_numbers": true,<br> "require_symbols": true,<br> "require_uppercase_characters": true<br>}</pre> |    no    |

## Outputs

| Name                                                                             | Description                                                                                                                                                                      |
| -------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <a name="output_id"></a> [id](#output_id)                                        | The AWS Account ID                                                                                                                                                               |
| <a name="output_name"></a> [name](#output_name)                                  | Name of the AWS account. The account alias.                                                                                                                                      |
| <a name="output_password_policy"></a> [password_policy](#output_password_policy) | Password Policy for the AWS Account. `expire_passwords` indicates whether passwords in the account expire. Returns `true` if `max_password_age` contains a value greater than 0. |
| <a name="output_signin_url"></a> [signin_url](#output_signin_url)                | The URL to signin for the AWS account.                                                                                                                                           |
