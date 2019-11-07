# Contributing to DragonPHY

## Using pull requests

We use pull requests (PRs) to manage updates to the code base, and block merging of PRs unless automated tests pass (they're stored in the **dragonphy/tests** subdirectory).  Here are the steps to go through to use this system.
1. Make sure that you're up-to-date with the latest changes from the **master** branch:
```shell
> git pull origin master
```
2. Create a new branch to store your work, and change to that branch.  The name of the branch should give some brief indictation of the feature that you're working on.  For example, you might call the branch **new_sampler** if it mainly represents an upgrade to the sampler design.
```shell
> git checkout -b NAME_OF_YOUR_BRANCH
```
3. Make changes to the code and commit them.
```shell
<make changes to code>
> git commit -am "description of changes"
```
4. Push code back to GitHub:
```shell
> git push origin NAME_OF_YOUR_BRANCH
```
5. Go to the [dragonphy GitHub page](https://github.com/StanfordVLSI/dragonphy).
6. Click Pull Requests -> New Pull Request.
7. Make sure "base" is at **master** and set **compare** to the name of your branch.
8. Add a title and description of your pull request and click "Create Pull Request".
  * If the tests pass, then you should be able to click a button at the bottom of the page to merge the pull request.  At that point it is safe to click the button that deletes the branch you created, since the changes have been merged into the **master** branch.
  * If the tests don't pass, then modify the code and push it to your branch.  The checks will automatically be re-run and the pull request will be updated with the build status.  In other words,
```shell
<make changes to code>
> git commit -am "description of changes"
> git push origin NAME_OF_YOUR_BRANCH
```
10. Now that the changes are merged, switch back to the **master** branch and pull the changes on you machine.
```shell
> git checkout master
> git pull origin master
```

## File Structure
Please have a look at the [wiki page](https://github.com/StanfordVLSI/dragonphy/wiki/File-Structure) on file structure to make sure that you're adding files in the right places.

## Other guidelines
1. Please do not commit any process-specific designs or information.  This is very important!
2. Please do not commit outputs from generators.  This clutters the repository and makes it harder to figure out what are the actual design sources vs. intermediate results.
3. Please make sure that automatically run tests do not take an excessive amount of time.  We want to make sure that pull requests can be verified in a reasonable amount of time (say ~1hr for all tests).
