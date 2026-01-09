# Langflow Bundles Reference

Bundles are third-party integrations that extend Langflow's capabilities. Install bundles to connect with external LLM providers, vector stores, observability tools, and specialized services.

## LLM Provider Bundles

### Cloud Providers

| Bundle | Use When | Configuration Notes |
|--------|----------|---------------------|
| **OpenAI** | GPT-4, GPT-4o, o1 models, embeddings, DALL-E | Requires `OPENAI_API_KEY`. Supports function calling and streaming |
| **Anthropic** | Claude models for reasoning, analysis, long context | Requires `ANTHROPIC_API_KEY`. Excellent for complex instructions |
| **Google** | Gemini models, multimodal capabilities | Requires Google AI API key or service account |
| **Azure OpenAI** | Enterprise OpenAI with Azure compliance | Requires endpoint URL, API key, and deployment names |
| **Amazon Bedrock** | AWS-native access to Claude, Titan, Llama | Uses AWS credentials. Good for existing AWS infrastructure |
| **Vertex AI** | Google Cloud managed AI models | Requires GCP project and service account |
| **IBM watsonx.ai** | Enterprise IBM models, granite | Requires watsonx credentials and project ID |

### Specialized Providers

| Bundle | Use When | Configuration Notes |
|--------|----------|---------------------|
| **Groq** | Ultra-fast inference for Llama, Mixtral | Requires `GROQ_API_KEY`. Best for latency-sensitive apps |
| **Mistral AI** | European provider, Mistral/Mixtral models | Requires Mistral API key. Good EU data residency option |
| **Cohere** | Retrieval, reranking, multilingual embeddings | Requires `COHERE_API_KEY`. Strong for RAG pipelines |
| **DeepSeek** | Cost-effective coding and reasoning | Requires DeepSeek API key |
| **xAI (Grok)** | Grok models with real-time knowledge | Requires xAI API key |
| **SambaNova** | High-throughput enterprise inference | Requires SambaNova credentials |
| **Hugging Face** | Open-source models, custom fine-tunes | Requires `HUGGINGFACE_API_KEY` for Inference API |

### Local Inference

| Bundle | Use When | Configuration Notes |
|--------|----------|---------------------|
| **Ollama** | Local model execution, privacy-first | Requires Ollama running locally. Set base URL if non-default |

## Vector Store Bundles

### Cloud-Native Stores

| Bundle | Use When | Configuration Notes |
|--------|----------|---------------------|
| **Pinecone** | Managed, scalable production vector search | Requires API key and environment. Serverless or pod-based |
| **Weaviate** | Schema-based, hybrid search, multi-tenancy | Cloud or self-hosted. Supports GraphQL queries |
| **Qdrant** | High-performance filtering, payload indexing | Cloud or self-hosted. Excellent filter capabilities |
| **Milvus** | Large-scale enterprise deployments | Self-hosted or Zilliz Cloud. GPU acceleration available |
| **DataStax Astra DB** | Cassandra-based, global distribution | Requires Astra credentials. Good for existing Cassandra users |
| **Vectara** | End-to-end RAG platform, grounded generation | Managed service with built-in reranking |

### Database Extensions

| Bundle | Use When | Configuration Notes |
|--------|----------|---------------------|
| **pgvector** | Add vectors to existing PostgreSQL | Requires PostgreSQL with pgvector extension |
| **Supabase** | PostgreSQL + vectors with auth/storage | Use Supabase project URL and API key |
| **MongoDB** | Vectors in existing MongoDB infrastructure | Requires Atlas or MongoDB 7.0+ with vector search |
| **Elasticsearch** | Combined text and vector search | Requires Elasticsearch 8.x with dense vectors enabled |
| **Redis** | Fast caching with vector similarity | Requires Redis Stack or Redis Enterprise |
| **Cassandra** | Distributed, high-availability vectors | Requires Cassandra 5.0+ with vector search |
| **Couchbase** | JSON documents with vector search | Requires Couchbase Server 7.6+ |

### Local/Lightweight

| Bundle | Use When | Configuration Notes |
|--------|----------|---------------------|
| **Chroma** | Development, prototyping, small datasets | Embedded by default. Can run as server |
| **FAISS** | CPU/GPU optimized local search, no server | In-memory or file-based persistence |

## Observability Bundles

| Bundle | Use When | Configuration Notes |
|--------|----------|---------------------|
| **Langfuse** | Open-source tracing, prompt management | Self-hosted or cloud. Set public/secret keys |
| **LangSmith** | LangChain ecosystem, detailed traces | Requires LangSmith API key. Best with LangChain components |
| **LangWatch** | Real-time monitoring, guardrails | Cloud service with dashboard |
| **Arize** | ML observability, drift detection | Production monitoring with Phoenix |
| **Opik** | Experiment tracking, evaluation | Open-source with Comet integration |

## Utility Bundles

### Data & Documents

| Bundle | Use When | Configuration Notes |
|--------|----------|---------------------|
| **Notion** | Load content from Notion workspaces | Requires integration token and database/page IDs |
| **Docling** | PDF, DOCX, PPTX document parsing | IBM's document processor. Handles complex layouts |
| **Wikipedia** | Knowledge base lookups, fact retrieval | No API key required for basic usage |

### Web & Search

| Bundle | Use When | Configuration Notes |
|--------|----------|---------------------|
| **Apify** | Web scraping, crawling at scale | Requires Apify API token. Access to pre-built actors |
| **SearchApi** | Google Search results programmatically | Requires SearchApi key |
| **Bing Search** | Microsoft search integration | Requires Azure Bing Search resource |
| **Exa Search** | Neural search for quality results | Requires Exa API key. Good for research |
| **DuckDuckGo** | Privacy-focused search, no API key | Rate limited. Good for prototyping |

### Agents & Memory

| Bundle | Use When | Configuration Notes |
|--------|----------|---------------------|
| **LangChain** | Access LangChain tools and chains | Core integration. Many components included |
| **Composio** | Pre-built tool integrations (GitHub, Slack, etc.) | Requires Composio API key |
| **Mem0** | Persistent memory across conversations | User/session memory management |
| **CUGA agent** | Custom agent architectures | Advanced agent workflows |

### Specialized

| Bundle | Use When | Configuration Notes |
|--------|----------|---------------------|
| **AssemblyAI** | Speech-to-text, audio intelligence | Requires AssemblyAI API key |
| **Cleanlab** | Data quality, label validation | Clean and validate training data |

## Installation

Install bundles via the Langflow UI or CLI:

```bash
# Example: Install a bundle
langflow install openai
```

## Documentation

For detailed configuration and component reference, see:
- `docs.langflow.org/bundles-{bundle-name}` for specific bundle docs
- `docs.langflow.org/configuration-environment-variables` for API key setup
