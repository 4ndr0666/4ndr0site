const dotenv = require('dotenv');
const { intro, isCancel, outro, spinner, text } = require('@clack/prompts');
const prompts = require('@clack/prompts');
const { Configuration, OpenAIApi } = require('openai');
const slugify = require('slugify');
const fs = require('fs');

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
    model: 'text-davinci-002',
    messages: prompt.messages,
  });

  // Print the response from the OpenAI API
  return response.data.choices[0].text.trim();
};

(async () => {
  const s = spinner();
  const messages = [];
  intro("Let's talk to ChatGPT (Ctrl-C or enter to end the conversation)...");
  while (true) {
    const question = await text({
      message: 'How can I help?',
    });
    if (isCancel(question) || !question || question.trim().length === 0) break;
    s.start('Thinking...');
    const answer = await askChatGPT(question, messages);
    messages.push(question, answer);
    s.stop(`Response: ${answer}`);
  }

  const timestamp = new Date().toISOString();
  const title = `Conversation ${timestamp}`;
  const directory = slugify(title.toLowerCase());

  if (!fs.existsSync(directory)) {
    fs.mkdirSync(directory);
  }

  const transcript = messages.map((m) => `> ${m}`).join('\n\n');

  fs.writeFileSync(`${directory}/transcript.md`, transcript);

  outro(`Conversation saved to ${directory}/transcript.md. Tokens used: X ($0.0Y cost). See you next time!`);
})();
