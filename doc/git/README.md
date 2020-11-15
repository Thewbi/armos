# Introduction to Git

If you are not familiar with git, git is a version control system develop by Linus Torvalds primarily for
use with the Linux kernel. It is used in almost all software development projects today. Version control
allows programmers to save their source code in the cloud so no data is lost. It also makes it possible
to precisely track version numbers and which changes where made to which files in which version which is
necessary for bug hunting and releasing version of your software. A distributed version control system
allows several developers to work together on a single code base.

With git, the general idea is that a software repository exists, which is called the remote repository.
Every developer sends their changes to the remote repository. Sending changes is called pushing. Also every
developer gets the latest changes by receiving files from the remote repository which is called pulling.

This remote repository is first copied onto your local harddrive which is called cloning.
Once cloned, changes can be made to the code. Every changed file has to be transfered from
the local repository to the remote repository so other developers and the build system can
work with the improvements. Transfering files back to the remote repository is called pushing.

Git works with branches. The repository is basically a set of branches. Each branch is independant of
other branches and contains source code in the repository. When several branches are alive in a
repository at the same time, different developers can make changes indepdenently to different branches.
Changing between branches is called checkout. You check out a branch and the folders and files on
your local harddrive change to the code that is contained in that branch. At any point in time you
are on exactly one branch. Usually the default branch called master is the current branch after cloning
a remote repository.

Branches are created to work on new features or bugs while the main line branch is still alive
and unchanged. This makes it possible to always release the mainline branch without other unfinished
features interfereing with the release process. Every branch that is created locally has to be pushed
to the remote repository eventually. When a branch is pushed, a remote copy of that branch is created
and your local branch is connected to that remote branch. This connection is called tracking. If you
checkout an existing remote branch, a local clone or copy is created of that remote branch and your
local copy also tracks that remote branch.

The challenge now becomes to merge branches back onto the
mainline branch. This can be challenging because if a file is changed by two branches simulatneously
on the exact same line of code, when bringing those to branches together, who decides how to
merge both changes together?

Git will automatically merge changes in different spots in the same file
because technically different lines do not conflict with each other. If git however finds that the same line
was changed during merging, it will not automatically merge but it will signal a conflict which is
to be manually resolved by the two developers that have changed the line! This can result in a lot of
blood, tiers and anger...

Not only can there be conflicts when merging two different branches together. It is also possible
that you work on the same branch that other developers also have checked out. That means changes can be
pushed to the same remote branch by different developers simultaneously. This in turn opens up the
situation where changes are present in the remote branch that you do not have on your local copy
while you have made local changes.

When loading data to your local copy, which is called pulling, you can get conflicts if you have
locally changed a file on a specific line that some other developer has also changed and pushed their
changes.

Now that some of the most relevant git concepts are talked about, there is one aspect that will make
everything easier for the beginner. This fact is that for following this course, you are most likely
the sole programmer in your OS project and hence conflicts are minimized and you do not have to care
about merging and conflict solving. The only thing you care about is make sure your code is save and
does not get lost.

To transfer changed files, the following steps are necessary

1. Pull from the remote branch to find out if someone changed the files in the meantime
2. Fix conflicts
3. Stage all changed files using git add
4. Commit the staged files
5. Push the commit

When files are changed, git will recognize the changed files.
The git status command lists all changed or added files.

To work with those changed or added files, these files have to go into the staging area first.

Git will only transfer commits. A commit is created from the current staging area.
Files that are not part of the staging area will not be part of a commit even if they are changed or added.
To add a file to the staging area, the git add command is used.

```
$ git add *
```

Once a subset or all files are staged, the staging area has to be commited.
When a commit is performed, git automatically stores the entire staging area in the commit.
To perform a commit, the command git commit is used. You have to specify a comment.

```
$ git commit -m "comment goes here"
```

Once you have a local commit, you can transfer that local commit to the remote branch. This is done via the
git push command.

```
$ git push
```

Because staging and commiting are separate from one another. You can first commit several times before transfering
all commits. Git allows you to work offline by first commiting locally several times. Then, when you get back
your internet connection, you can commit all your changes to the remote repository.

How to split and package changes into commits is a highly individual preference. Best practice is to never commit
anything to the remote repository that does not run. A eye-opening read about how to be succesfull with
software development in a team is the talk by John Romero. https://www.youtube.com/watch?v=KFziBfvAFnM
He knows what he is talking about.
