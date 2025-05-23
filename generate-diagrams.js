const fs = require('fs-extra');
const path = require('path');
const axios = require('axios');
const plantumlEncoder = require('plantuml-encoder');

// Configuration
const inputDir = path.resolve(__dirname, 'diagrams');
const outputDir = path.resolve(__dirname, 'img');
const plantUmlServer = 'https://www.plantuml.com/plantuml/svg';

// Ensure output directory exists
fs.ensureDirSync(outputDir);

// Process each .puml file
fs.readdirSync(inputDir)
  .filter(file => file.endsWith('.puml'))
  .forEach(async (file) => {
    const fullPath = path.join(inputDir, file);
    const content = await fs.readFile(fullPath, 'utf-8');

    const encoded = plantumlEncoder.encode(content);
    const url = `${plantUmlServer}/${encoded}`;

    try {
      const response = await axios.get(url);
      const outputFile = path.join(outputDir, file.replace('.puml', '.svg'));
      await fs.writeFile(outputFile, response.data, 'utf-8');
      console.log(`✅ Generated: ${outputFile}`);
    } catch (err) {
      console.error(`❌ Failed to generate diagram for ${file}:`, err.message);
    }
  });
