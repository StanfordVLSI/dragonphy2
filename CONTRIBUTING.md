# Contributing to DragonPHY

## Using pull requests

We use pull requests (PRs) to manage updates to the code base, and block merging of PRs unless automated tests pass (they're stored in the **dragonphy/tests** subdirectory).  Here are the steps to go through to use this system.
1. Make sure that you're up-to-date with the latest changes from the **master** branch:
```shell
> git pull origin master
```
2. Create a new branch to store your work, and change to that branch.  The name of the branch should give some brief indictation of the feature that you're working on.
```shell
> git checkout -b NAME_OF_YOUR_BRANCH
```
3. Make changes to the code and commit them.
```shell
...
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
...
> git commit -am "description of changes"
> git push origin NAME_OF_YOUR_BRANCH
```
10. Now that the changes are merged, switch back to the **master** branch and pull the changes on you machine.
```shell
> git checkout master
> git pull origin master
```

## File structure
1. Python code should be placed in the **dragonphy/dragonphy** subdirectory.
2. Verilog code related to the receiver design should go in the **dragonphy/src** subdirectory.
