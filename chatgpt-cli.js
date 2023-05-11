const dotenv = require('dotenv');
const { intro, isCancel, outro, spinner } = require('@clack/prompts');
const { Configuration, OpenAIApi } = require('openai');
const slugify = require('slugify');
const fs = require('fs');
const readline = require('readline');

// Load environment variables from .env file
dotenv.config();

// Set up the OpenAI API client
const configuration = new Configuration({
  apiKey: process.env.OPENAI_API_KEY,
  organization: process.env.OPENAI_ORG,
});
const openaiClient = new OpenAIApi(configuration);

// Start the conversation with the OpenAI API
const askChatGPT = async (question, messages) => {
  const prompt = {
    messages: [],
  };
  for (let i = Math.max(messages.length - 20, 0); i < messages.length; i++) {
    const m = messages[i];
    prompt.messages.push({
      role: i % 2 === 0 ? 'user' : 'assistant',
      content: m,
    });
  }
  prompt.messages.push({
    role: 'user',
    content: question,
  });

  const response = await openaiClient.createChatCompletion({
    model: 'gpt-3.5-turbo',
    messages: prompt.messages,
  });

  // Print the response from the OpenAI API
  return response.data.choices[0].message.content.trim();
};

(async () => {
  const s = spinner();
  const messages = [];
  intro("AI online...");

  const endDelimiter = 'EOF';
  let question = '';

  console.log('Yes Master? (Type "EOF" on a new line and press Enter to submit)');

  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  const processQuestion = async () => {
    if (isCancel(question) || !question || question.trim().length === 0) {
      rl.close();
    } else {
      s.start('Thinking...');
      const answer = await askChatGPT(question, messages);
      messages.push(question, answer);
      s.stop(`Response: ${answer}`);
      console.log('Yes Master? (Type "EOF" on a new line and press Enter to submit)');
      question = '';
    }
  };

  rl.on('line', async (line) => {
    if (line === endDelimiter) {
      await processQuestion();
    } else {
      question += line + '\n';
    }
  });

  rl.on('close', () => {
    const timestamp = new Date().toISOString();
    const title = `Conversation ${timestamp}`;
    const directory = 'content/' + slugify(title.toLowerCase());

    if (!fs.existsSync('content')) {
      fs.mkdirSync('content');
    }

    if (!fs.existsSync(directory)) {
      fs.mkdirSync(directory);
    }

    const transcript = messages.map((m) => `> ${m}`).join('\n\n');

    fs.writeFileSync(`${directory}/transcript.md`, transcript);

    outro(`Conversation saved to ${directory}/transcript.md. Tokens used: X ($0.0Y cost). See you next time!`);
  });

})();
