import React, { useState } from 'react';
import { createRoot } from 'react-dom/client';
import './style.css';

const API_URL = 'http://localhost:8000';

function App() {
  const [text, setText] = useState('MyOwnAI is a local RAG assistant built with React, FastAPI, Ollama, Llama 3, LangChain, Qdrant, and Docker.');
  const [question, setQuestion] = useState('What is MyOwnAI built with?');
  const [answer, setAnswer] = useState('');
  const [sources, setSources] = useState([]);
  const [loading, setLoading] = useState(false);

  async function ingestText() {
    setLoading(true);
    try {
      const response = await fetch(`${API_URL}/ingest`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ texts: [text] }),
      });
      const data = await response.json();
      setAnswer(`Ingest result: ${data.message}. Added: ${data.added}`);
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
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ question }),
      });
      const data = await response.json();
      setAnswer(data.answer);
      setSources(data.sources || []);
    } catch (error) {
      setAnswer(`Error: ${error.message}`);
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="page">
      <section className="card">
        <h1>MyOwnAI Test Project</h1>
        <p className="subtitle">Local RAG: React → FastAPI → LangChain → Qdrant → Ollama/Llama 3</p>

        <label>Document text</label>
        <textarea value={text} onChange={(e) => setText(e.target.value)} />
        <button onClick={ingestText} disabled={loading}>Add to Qdrant</button>

        <label>Question</label>
        <input value={question} onChange={(e) => setQuestion(e.target.value)} />
        <button onClick={askQuestion} disabled={loading}>Ask AI</button>

        <div className="answer">
          <h2>Answer</h2>
          <p>{loading ? 'Thinking...' : answer}</p>
        </div>

        {sources.length > 0 && (
          <div className="sources">
            <h2>Retrieved context</h2>
            {sources.map((source, index) => <pre key={index}>{source}</pre>)}
          </div>
        )}
      </section>
    </main>
  );
}

createRoot(document.getElementById('root')).render(<App />);
