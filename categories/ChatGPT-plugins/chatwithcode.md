# ChatWithCode Demonstration

## Using ChatWithCode in a Script

### Fetching Repository File Structure

```python
# Using ChatWithCode to fetch the file structure of a GitHub repository
repositoryUrl = "https://github.com/4ndr0666/4ndr0site"
file_structure = chatwithcode.FetchRepoFileStructure(repositoryUrl=repositoryUrl)
print(file_structure)
```

### Retrieving File Contents

```python
# Using ChatWithCode to retrieve the contents of specific files in a GitHub repository
filePaths = ["scripts/script.py"]
file_contents = chatwithcode.FetchFileContentsFromRepo(repositoryUrl=repositoryUrl, filePaths=filePaths)
print(file_contents)
```

### Extracting Functions from Repository Files

```python
# Using ChatWithCode to extract functions from specific files in a GitHub repository
functions = chatwithcode.ExtractFunctionsFromRepoFiles(repositoryUrl=repositoryUrl, filePaths=filePaths)
print(functions)
```

## Direct Interaction Instructions on the Platform

### 1. Fetching Repository File Structure

**Instruction**: 
```
Fetch the file structure of my repository at https://github.com/4ndr0666/4ndr0site.
```

### 2. Retrieving File Contents

**Instruction**: 
```
Retrieve the contents of the file "scripts/script.py" from my repository at https://github.com/4ndr0666/4ndr0site.
```

### 3. Extracting Functions from Repository Files

**Instruction**: 
```
Extract functions from the file "scripts/script.py" in my repository at https://github.com/4ndr0666/4ndr0site.
```
