import React, { useState } from 'react';
import { createRoot } from 'react-dom/client';
import './style.css';

const API_URL = 'http://localhost:8000';

function App() {
  const [text, setText] = useState(
    'MyOwnAI is a local RAG assistant built with React, FastAPI, Ollama, Llama 3, LangChain, Qdrant, and Docker.'
  );
  const [file, setFile] = useState(null);
  const [question, setQuestion] = useState('What is MyOwnAI built with?');
  const [answer, setAnswer] = useState('');
  const [sources, setSources] = useState([]);
  const [loading, setLoading] = useState(false);

  async function ingestText() {
    setLoading(true);

    try {
      const response = await fetch(`${API_URL}/ingest`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ texts: [text] }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.detail || 'Failed to ingest text');
      }

      setAnswer(`Ingest result: ${data.message}. Added: ${data.added}`);
      setSources([]);
    } catch (error) {
      setAnswer(`Error: ${error.message}`);
    } finally {
      setLoading(false);
    }
  }

  async function uploadFile() {
    if (!file) {
      setAnswer('Please select a .txt, .pdf, or .docx file first.');
      return;
    }

    setLoading(true);

    try {
      const formData = new FormData();
      formData.append('file', file);

      const response = await fetch(`${API_URL}/upload`, {
        method: 'POST',
        body: formData,
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.detail || 'Failed to upload file');
      }

      setAnswer(`Upload result: ${data.message}. File: ${data.filename}. Chunks: ${data.chunks}`);
      setSources([]);
    } catch (error) {
      setAnswer(`Error: ${error.message}`);
    } finally {
      setLoading(false);
    }
  }

  async function askQuestion() {
    setLoading(true);

    try {
      const response = await fetch(`${API_URL}/ask`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ question }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.detail || 'Failed to ask AI');
      }

      setAnswer(data.answer);
      setSources(data.sources || []);
    } catch (error) {
      setAnswer(`Error: ${error.message}`);
    } finally {
      setLoading(false);
    }
  }

  return (
    <main>
      <section>
        <h1>MyOwnAI Test Project</h1>
        <p>Local RAG: React → FastAPI → LangChain → Qdrant → Ollama/Llama 3</p>

        <label>Document text</label>
        <textarea value={text} onChange={(e) => setText(e.target.value)} />
        <button onClick={ingestText} disabled={loading}>
          Add text to Qdrant
        </button>

        <label>Upload document</label>
        <input
          type="file"
          accept=".txt,.pdf,.docx"
          onChange={(e) => setFile(e.target.files?.[0] || null)}
        />
        <button onClick={uploadFile} disabled={loading}>
          Upload file to Qdrant
        </button>

        <label>Question</label>
        <input value={question} onChange={(e) => setQuestion(e.target.value)} />
        <button onClick={askQuestion} disabled={loading}>
          Ask AI
        </button>

        <div className="answer">
          <h2>Answer</h2>
          <p>{loading ? 'Thinking...' : answer}</p>
        </div>

        {sources.length > 0 && (
          <div className="sources">
            <h2>Retrieved context</h2>
            {sources.map((source, index) => (
              <pre key={index}>
                {typeof source === 'string'
                  ? source
                  : `Source: ${source.source}\n\n${source.content}`}
              </pre>
            ))}
          </div>
        )}
      </section>
    </main>
  );
}

createRoot(document.getElementById('root')).render(<App />);