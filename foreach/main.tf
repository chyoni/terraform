provider "aws" {
  region = "ap-northeast-2"
}

# ---------
# count

/* resource "aws_iam_user" "count" {
  count = 5
  name  = "count-user-${count.index}"
}

output "count_user_arns" {
  value = aws_iam_user.count.*.arn
} */

# ----------
# for_each (set)

/* resource "aws_iam_user" "for_each_set" {
  for_each = toset([
    "for-each-set-user-1",
    "for-each-set-user-2",
    "for-each-set-user-3",
  ])

  name = each.key
}

output "for_each_set_user_arns" {
  value = values(aws_iam_user.for_each_set).*.arn
} */

# ----------
# for_each (map)

resource "aws_iam_user" "for_each_map" {
  for_each = {
    "alice" = {
      level   = "low"
      manager = "chyonee"
    }
    "bob" = {
      level   = "mid"
      manager = "chyonee"
    }
    "john" = {
      level   = "high"
      manager = "chyonee"
    }
  }

  name = each.key
  tags = each.value
}

output "for_each_map_user_arns" {
  value = values(aws_iam_user.for_each_map).*.arn
}

