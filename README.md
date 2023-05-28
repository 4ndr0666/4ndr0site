<<<<<<< HEAD
# GPT Compendium

This repository is a collection of transcripts of conversations with the OpenAI GPT language model. Each conversation is stored in a separate directory, with the directory name indicating the date of the conversation.

## Installation

First, clone the GPT Compendium repository to your local machine by running the following command in your terminal:

git clone https://github.com/4ndr0666/gptcompendium.git


Install the required dependencies by running the following command in the root directory of the repository:

npm install


Next, you'll need to set up your OpenAI API credentials. If you don't have an OpenAI API key yet, you can sign up for one at https://beta.openai.com/signup/.

Once you have your API key, create a new file in the root directory of the repository called .env and add the following lines to it, replacing <your-api-key> with your actual API key:

OPENAI_API_KEY=<your-api-key>
OPENAI_API_ORG=org-iuuLPItqeNz4EmQ36WblqKgM

## Usage

To start a conversation with the OpenAI GPT language model, run the following command in the root directory of the repository:

npm start


This will launch the chatgpt-cli.js script and start a conversation with the GPT language model.

To end the conversation, press Ctrl-C.

After you've had a conversation, you can add it to the GPT Compendium by following these steps:

1. Create a new directory in the content directory of the repository with the date of the conversation in the format YYYY-MM-DD.
2. Inside the new directory, create a new file called transcript.md and copy and paste the transcript of the conversation into it.
3. If you want to include additional information about the conversation, such as a description or notes, you can create a new file called metadata.json in the same directory and add the information in JSON format.

Once you've added a conversation, you can build and deploy the GPT Compendium by running the following command in the root directory of the repository:

npm run deploy


This will build the website and deploy it to the gh-pages branch of the repository, making it available at https://<your-github-username>.github.io/gptcompendium.

## Contributing

If you would like to contribute to the GPT Compendium, please see the [contributing guidelines](CONTRIBUTING.md).
=======
# Website

My site for an online collection of transcripts , scripts, files and tools. 
>>>>>>> origin/main

## License

This repository is licensed under the [MIT License](LICENSE).
