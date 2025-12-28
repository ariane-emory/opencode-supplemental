We'd like to limit the ammount of unnecessary 'code churn' in the repository. Look at the output of this command and analyze the changes relative to the dev branch:

git diff dev..HEAD;

Once you've analyzed the diff, detemine whether any of this content can be safely removed while still resolving the afoementioned GH issue and proceed to carefully remove it. We only want the changes that are truly required to resolve the issue.
