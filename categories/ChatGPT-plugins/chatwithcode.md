# ChatWithCode Demonstration

## Fetching Repository File Structure

```python
# Using ChatWithCode to fetch the file structure of a GitHub repository
repositoryUrl = "https://github.com/YourUsername/YourRepoName"
file_structure = chatwithcode.FetchRepoFileStructure(repositoryUrl=repositoryUrl)
print(file_structure)
```

## Retrieving File Contents

```python
# Using ChatWithCode to retrieve the contents of specific files in a GitHub repository
filePaths = ["path/to/your/file1", "path/to/your/file2"]
file_contents = chatwithcode.FetchFileContentsFromRepo(repositoryUrl=repositoryUrl, filePaths=filePaths)
print(file_contents)
```

## Extracting Functions from Repository Files

```python
# Using ChatWithCode to extract functions from specific files in a GitHub repository
functions = chatwithcode.ExtractFunctionsFromRepoFiles(repositoryUrl=repositoryUrl, filePaths=filePaths)
print(functions)
```
