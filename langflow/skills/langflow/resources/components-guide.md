# Langflow Components Guide

Components are the building blocks of Langflow flows. Each component performs a specific function and can be connected to other components via typed ports.

## Component Structure

Every component has:
- **Inputs**: Data or configuration received from other components or user
- **Outputs**: Data produced and sent to connected components
- **Parameters**: Configuration options shown in the visual editor
- **Ports**: Connection points (colored by data type)

## Component Categories

### Core Components

Located in the **Core components** menu:

| Category | Examples | Purpose |
|----------|----------|---------|
| **Inputs/Outputs** | Chat Input, Chat Output, Text Input | Flow entry/exit points |
| **Data** | File, URL, Directory, API Request | Data loading |
| **Processing** | Text Splitter, Parser, Filter | Data transformation |
| **Models** | OpenAI, Anthropic, Ollama | LLM integration |
| **Embeddings** | OpenAI Embeddings, HuggingFace | Vector generation |
| **Vector Stores** | Chroma, Pinecone, FAISS | Vector storage/retrieval |
| **Agents** | Agent, MCP Tools | Agentic workflows |
| **Memory** | Message History | Conversation context |
| **Logic** | If-Else, Loop, Router | Flow control |
| **Utilities** | Calculator, Current Date | Helper functions |

### Bundles

Provider-specific components grouped by service:
- **OpenAI**: ChatGPT, GPT-4, DALL-E, Whisper
- **Anthropic**: Claude models
- **Google**: Gemini, Vertex AI
- **AWS**: Bedrock models
- **And many more...**

## Data Types and Port Colors

Components communicate via typed ports. Port colors indicate data types:

| Port Color | Data Type | Description |
|------------|-----------|-------------|
| Red | `Data` | Structured key-value data |
| Pink | `DataFrame` | Tabular data (pandas) |
| Emerald | `Embeddings` | Vector embeddings |
| Fuchsia | `LanguageModel` | LLM instance |
| Orange | `Memory` | Chat memory |
| Indigo | `Message` | Chat messages |
| Cyan | `Tool` | Agent tools |
| Gray | Unknown | Multiple types accepted |

### Data Type Schemas

**Message** (`Message`):
```python
{
    "text": "Hello!",
    "sender": "User",           # or "Machine"
    "sender_name": "User",
    "session_id": "abc123",
    "timestamp": "2024-01-01T12:00:00Z",
    "files": [],
    "content_blocks": [],
    "category": "message"
}
```

**Data** (`Data`):
```python
{
    "text_key": "text",
    "data": {
        "text": "Primary content",
        "key1": "value1",
        "key2": 123
    },
    "default_value": ""
}
```

**DataFrame** (`DataFrame`):
```python
# Pandas DataFrame with additional methods:
df.to_data_list()      # Convert to list of Data objects
df.add_row(data)       # Add single row
df.to_message()        # Convert to Message
```

## Using Components

### Adding Components

1. Drag from sidebar menu to canvas
2. Or press `/` and search by name
3. Or right-click canvas → Add Component

### Configuring Components

Click component to access:
- **Parameters panel**: Edit settings
- **Code button**: View/edit Python code
- **Controls**: Access all parameters
- **Tool Mode toggle**: Enable for agent use

### Connecting Components

1. Click output port (right side)
2. Drag to input port (left side)
3. Same-color ports are compatible
4. Use **Type Convert** for mismatched types

## Key Components

### Chat Input / Chat Output

Entry and exit points for chat-based flows.

**Chat Input**:
- Receives user messages
- Outputs `Message` type
- Stores messages in session history

**Chat Output**:
- Displays responses in Playground
- Accepts `Message` input
- Required for chat widget embedding

### Agent Component

Central component for agentic flows:

```
┌─────────────────────────────────────────┐
│              Agent                       │
├─────────────────────────────────────────┤
│ Model Provider: [OpenAI ▼]              │
│ Model Name: [gpt-4o-mini ▼]             │
│ API Key: [••••••••]                     │
│ Agent Instructions: [System prompt...]   │
├─────────────────────────────────────────┤
│ Input ○────────────────────○ Response   │
│ Tools ○                                 │
│ Memory ○                                │
└─────────────────────────────────────────┘
```

**Key Parameters**:
- `agent_llm`: Model provider selection
- `llm_model`: Specific model name
- `system_prompt`: Agent instructions
- `tools`: Connected tool components
- `add_current_date_tool`: Include date tool

### Language Models

LLM components for text generation:

**Output Types**:
1. **Model Response** (`Message`): Direct text output
2. **Language Model** (`LanguageModel`): LLM instance for chaining

Common parameters:
- `model_name`: Model identifier
- `temperature`: Creativity (0-2)
- `max_tokens`: Response length limit
- `api_key`: Provider authentication

### Vector Stores

For RAG (Retrieval Augmented Generation):

**Ingest Mode**:
```
Documents → Text Splitter → Embedding Model → Vector Store (Ingest)
```

**Search Mode**:
```
Query → Embedding Model → Vector Store (Search) → Retrieved Documents
```

### Prompt Template

Creates dynamic prompts with variables:

```
Template: "Answer about {topic} in {language}"
         ↓
Variables auto-detected: topic, language
         ↓
New input ports created for each variable
```

## Tool Mode

Enable **Tool Mode** to use any component as an agent tool:

1. Click component header
2. Toggle **Tool Mode** ON
3. Connect **Toolset** port to Agent's **Tools** port

Components in Tool Mode:
- Receive requests from Agent
- Execute their normal function
- Return results to Agent
- Include description for Agent's tool selection

## Component Execution

### Single Component Run

Click **Run Component** button:
1. Builds only that component
2. Uses direct input values
3. Does NOT run upstream components
4. Shows **Last Run** timestamp on success

### Flow Execution

Run entire flow:
1. Builds dependency graph (DAG)
2. Topologically sorts components
3. Executes in order, passing results
4. Streams events to frontend

### Component States

| State | Icon | Meaning |
|-------|------|---------|
| Idle | Gray | Not yet run |
| Building | Spinner | Currently executing |
| Success | Green check | Completed successfully |
| Error | Red X | Failed with error |
| Frozen | Snowflake | Cached, won't re-run |

## Freezing Components

Freeze a component to preserve its output:
1. Click component → Show More → Freeze
2. Component and all upstream components are frozen
3. Future runs use cached output
4. Unfreeze to re-execute

Use when:
- Expensive operations (API calls, embeddings)
- Consistent output needed
- Debugging downstream components

## Grouping Components

Combine multiple components into a reusable group:

1. Select components (Shift+drag or Ctrl+click)
2. Click **Group**
3. Grouped component has single interface
4. Ungroup to edit individual components
5. Save to Core components for reuse

## Legacy Components

Deprecated components hidden by default:
- May be removed in future versions
- Suggested replacements in component banner
- Toggle visibility in Component Settings

## Component Inspection

### Inspect Output

After running, click **Inspect** to view:
- Component output data
- Execution logs
- Error messages
- Timing information

### View Code

Click **Code** to see Python implementation:
- Input/output definitions
- Build method logic
- Helpful for debugging
- Can edit for customization

## Best Practices

1. **Start simple**: Begin with basic flows, add complexity gradually
2. **Use Tool Mode**: Leverage agents for complex decision-making
3. **Freeze expensive ops**: Cache embeddings, API calls
4. **Check port colors**: Ensure compatible connections
5. **Inspect outputs**: Debug by checking intermediate results
6. **Group related components**: Keep flows organized
7. **Use templates**: Start from pre-built examples
