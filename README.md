# seclocker

The idea is that in every AWS environment there should be a service to listen to the logs
and whenever an unathorised login is made to the server and action should be triggered
without human intervention.

Also, the solution should be deployable into an exsiting environment without impacting
functionality. For that the code is sperated into multiple parts:
 * terraform module to create the infra for the logs (log stream, filters, iam policies, etc)
 * an ansible module to deploy the cw agent on a box (if you're already running cw log agent this can be skipped)
 * lambda function(s) to be triggered whenever a breach occurs with some configurble actions
 * test terraform module to create a testbed
 * makefile for ease-of-use

## Inspiration

* https://aws.amazon.com/blogs/security/how-to-monitor-and-visualize-failed-ssh-access-attempts-to-amazon-ec2-linux-instances/
* https://aws.amazon.com/blogs/security/how-to-visualize-and-refine-your-networks-security-by-adding-security-group-ids-to-your-vpc-flow-logs/
* https://docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html