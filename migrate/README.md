# migration path (very premature atm)

This is just a proof-of-concept at this point. It has minimal changes to the terraform, but does require manual configuration of subnets. Perhaps that could be rolled into lifecycle ignores instead, but with the cidrs and such being auto-computed I wasn't sure if that was the best move.

Everything other than the subnet configuration is straightforward, maps 1:1, which just minor naming stuff to direct terraform to ignore.

If you plug a three-az CDK stack into `stack_name` of `get_imports.py`, then run `get_imports.py`, it should output a list of terraform import commands you can run that will import extant CDK resources into the current terraform state.

So an example migration would be something like this:

    terraform init
    # edit stack name in file
    ./get_imports.py
    # Make sure it works / doesn't look weird
    ./get_imports.py > imports.sh
    bash ./imports.sh
    terraform apply

Presuming there are no unexpected genuine terraform provisioning errors, you'll likely get to the point where it's trying to run mallory and proxy into the kubernetes server. My expectation at this point is that kubeconfig will _not_ be functional. I had to copy a pre-existing kubeconfig to get access at this point, as it's missing the `--role` that was created with the original incarnation.

After this, the aws-auth didn't quite work. kubectl logs/exec would fail, though most other kubectl things worked. I fiddled with the aws-auth configmap until everything seemed to work.

Domino appeared functional (UI loaded), but was running on the original ASGs. This process doesn't convert the ASGs, but lets the new ones take over. It also doesn't remove the old ones, hence it was running on the old ones.

I set all those to 0, set one new platform asg to 1. The cluster-autoscaler didn't seem to be functional, thinking it couldn't scale the rest of the nodes up.

I manually scaled every platform/compute ASG to 1, after which Domino appeared functional. I built an enviornment, a model, tested the model and tested a workspace.

I did randomly get logged out once, which was weird. This happened during a model build, which also failed. Not sure what happened, didn't look into it. Subsequent rebuild was totally fine.

Important note: _I TESTED THIS WITH A 5.1.4 INSTALL_

# Obvious TODOs

* Go through IAM differences and make sure everything actually gets set up correctly
  * Most obvious thing is that the kubeconfig works
  * Permissions should be set up identical to new EKS terraform installs, but clearly weren't
* Go through aws-auth differences and do the same thing
* Figure out wtf is wrong with the autoscaler
  * I tried adding some of the tags that were different, but it didn't make a difference
  * Didn't dig any deeper
* Make a script to collate all the resources for every nested stack and then, in reverse order, run something like this for each one:
  * aws cloudformation delete-stack some-nested-stack --retain-resources every,logical,id,in,the,stack

If all these things happen, I think we have a realistic migration path away from CDK that doesn't involve a lift-and-shift
