# Creating Custom Components

Custom components extend Langflow with new functionality. They're Python classes that inherit from the `Component` base class.

## Quick Start

```python
from lfx.custom.custom_component.component import Component
from lfx.io import StrInput, Output, Message

class HelloWorld(Component):
    display_name = "Hello World"
    description = "A simple greeting component"
    icon = "Smile"  # Lucide icon name

    inputs = [
        StrInput(
            name="name",
            display_name="Name",
            info="Name to greet"
        )
    ]

    outputs = [
        Output(
            name="greeting",
            display_name="Greeting",
            method="greet"
        )
    ]

    def greet(self) -> Message:
        return Message(text=f"Hello, {self.name}!")
```

## Component Structure

### Class Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `display_name` | str | Name shown in UI |
| `description` | str | Component description |
| `documentation` | str | Link to docs (optional) |
| `icon` | str | Lucide icon name |
| `name` | str | Internal identifier (optional) |
| `priority` | int | Menu order (lower = first) |

### Icons

Use any [Lucide icon](https://lucide.dev/icons) name:
- `"Sparkles"`, `"Brain"`, `"Database"`
- `"FileText"`, `"Globe"`, `"Code"`

## Input Types

Import from `lfx.io`:

```python
from lfx.io import (
    StrInput,           # Single-line text
    MultilineInput,     # Multi-line text
    IntInput,           # Integer
    FloatInput,         # Float
    BoolInput,          # Toggle
    DropdownInput,      # Selection
    FileInput,          # File upload
    CodeInput,          # Code editor
    DataInput,          # Data object
    MessageTextInput,   # Message-compatible text
    HandleInput,        # Generic handle
)
```

### Input Parameters

```python
StrInput(
    name="field_name",           # Access via self.field_name
    display_name="Field Name",   # UI label
    info="Help text",            # Tooltip
    value="default",             # Default value
    required=True,               # Required field
    advanced=False,              # Show in advanced section
    show=True,                   # Visible by default
    dynamic=False,               # Can change at runtime
    real_time_refresh=False,     # Trigger update_build_config
    tool_mode=False,             # Enable Tool Mode support
)
```

### Dropdown Input

```python
DropdownInput(
    name="model",
    display_name="Model",
    options=["gpt-4", "gpt-3.5-turbo", "claude-3"],
    value="gpt-4"
)
```

### Boolean Input

```python
BoolInput(
    name="enabled",
    display_name="Enabled",
    value=True  # Default checked
)
```

### Data Input

```python
DataInput(
    name="data_input",
    display_name="Input Data",
    input_types=["Document", "Data"],  # Accepted types
)
```

## Output Types

```python
from lfx.io import Output
from lfx.schema import Data, DataFrame, Message

outputs = [
    Output(
        name="output_name",
        display_name="Output Label",
        method="method_name"  # Must match method name
    )
]
```

### Return Types

| Type | Import | Use Case |
|------|--------|----------|
| `Message` | `lfx.schema` | Chat messages |
| `Data` | `lfx.schema` | Structured data |
| `DataFrame` | `lfx.schema` | Tabular data |
| `str`, `int`, etc. | Built-in | Simple values |

### Multiple Outputs

```python
outputs = [
    Output(name="success", display_name="Success", method="on_success"),
    Output(name="error", display_name="Error", method="on_error"),
]

# Default: user selects ONE output
# Set group_outputs=True for ALL outputs simultaneously:
outputs = [
    Output(name="data", method="get_data", group_outputs=True),
    Output(name="count", method="get_count", group_outputs=True),
]
```

## Output Methods

Methods linked to outputs:

```python
def process(self) -> Message:
    # Access inputs via self.input_name
    result = self.input_text.upper()

    # Set status message (shown in UI)
    self.status = f"Processed {len(result)} characters"

    return Message(text=result)
```

### Using Context

Share data between methods:

```python
def _pre_run_setup(self):
    self.ctx["counter"] = 0

def process_item(self) -> Data:
    self.ctx["counter"] += 1
    return Data(data={"count": self.ctx["counter"]})
```

## Dynamic Fields

Show/hide fields based on user selections:

```python
inputs = [
    DropdownInput(
        name="mode",
        display_name="Mode",
        options=["simple", "advanced"],
        value="simple",
        real_time_refresh=True  # Triggers update_build_config
    ),
    StrInput(
        name="advanced_option",
        display_name="Advanced Option",
        dynamic=True,
        show=False  # Hidden by default
    )
]

def update_build_config(self, build_config: dict,
                         field_value: str,
                         field_name: str | None = None) -> dict:
    if field_name == "mode":
        build_config["advanced_option"]["show"] = (field_value == "advanced")
    return build_config
```

## Tool Mode Support

Enable component for use as an Agent tool:

```python
inputs = [
    MessageTextInput(
        name="query",
        display_name="Query",
        tool_mode=True  # Enables Tool Mode
    )
]
```

## Error Handling

### Raise Exceptions

```python
def process(self) -> Data:
    if not self.input_text:
        raise ValueError("Input text is required")
    # ... process
```

### Return Error Data

```python
def process(self) -> Data:
    try:
        result = some_operation()
        return Data(data={"result": result})
    except Exception as e:
        return Data(data={"error": str(e)})
```

### Stop Output

```python
def process(self) -> Data:
    if not self.is_valid:
        self.stop("output_name")  # Stops this output path
        return Data(data={"error": "Invalid input"})
    # ... continue
```

## Logging

```python
def process(self) -> Data:
    self.log("Starting process...")
    # Logs appear in component's Logs panel

    self.status = "Processing complete"
    # Status shown on component in UI
```

## File Organization

### Directory Structure

```
src/lfx/src/lfx/components/
└── {category}/                  # Category name (lowercase)
    ├── __init__.py              # Required
    └── my_component.py          # Component file
```

### Custom Components Path

For external components:
```
/your/custom/path/
└── {category}/
    ├── __init__.py
    └── component.py
```

Set `LANGFLOW_COMPONENTS_PATH=/your/custom/path`

### __init__.py

Standard import:
```python
from .my_component import MyComponent

__all__ = ["MyComponent"]
```

Lazy loading (better performance):
```python
from __future__ import annotations
from typing import TYPE_CHECKING, Any
from lfx.components._importing import import_mod

if TYPE_CHECKING:
    from lfx.components.data.my_component import MyComponent

_dynamic_imports = {
    "MyComponent": "my_component",
}

__all__ = ["MyComponent"]

def __getattr__(attr_name: str) -> Any:
    if attr_name not in _dynamic_imports:
        raise AttributeError(f"module has no attribute '{attr_name}'")
    result = import_mod(attr_name, _dynamic_imports[attr_name], __spec__.parent)
    globals()[attr_name] = result
    return result
```

## Loading Custom Components

### Local Development

1. Save component to `src/lfx/src/lfx/components/{category}/`
2. Update `__init__.py`
3. Rebuild: `make install_backend`
4. Refresh Langflow

### Docker

```bash
docker run -d \
  --name langflow \
  -p 7860:7860 \
  -v ./custom_components:/app/custom_components \
  -e LANGFLOW_COMPONENTS_PATH=/app/custom_components \
  langflowai/langflow:latest
```

## Complete Example

```python
from typing import Any
import pandas as pd

from lfx.custom.custom_component.component import Component
from lfx.io import (
    StrInput,
    IntInput,
    BoolInput,
    DropdownInput,
    DataInput,
    Output
)
from lfx.schema import Data, DataFrame, Message


class DataFrameProcessor(Component):
    """Process and transform pandas DataFrames."""

    display_name = "DataFrame Processor"
    description = "Filter, sort, and transform DataFrames"
    documentation = "https://docs.langflow.org/components-dataframe-processor"
    icon = "Table"
    priority = 100

    inputs = [
        DataInput(
            name="data_input",
            display_name="Input Data",
            info="Data to process",
            input_types=["Data", "DataFrame"]
        ),
        DropdownInput(
            name="operation",
            display_name="Operation",
            options=["filter", "sort", "limit"],
            value="filter",
            real_time_refresh=True
        ),
        StrInput(
            name="filter_column",
            display_name="Filter Column",
            dynamic=True,
            show=False
        ),
        StrInput(
            name="filter_value",
            display_name="Filter Value",
            dynamic=True,
            show=False
        ),
        StrInput(
            name="sort_column",
            display_name="Sort Column",
            dynamic=True,
            show=False
        ),
        BoolInput(
            name="ascending",
            display_name="Ascending",
            value=True,
            dynamic=True,
            show=False
        ),
        IntInput(
            name="limit",
            display_name="Limit",
            value=10,
            dynamic=True,
            show=False
        )
    ]

    outputs = [
        Output(
            name="processed_data",
            display_name="Processed Data",
            method="process"
        )
    ]

    def update_build_config(self, build_config: dict,
                           field_value: str,
                           field_name: str | None = None) -> dict:
        if field_name == "operation":
            # Hide all operation-specific fields
            for field in ["filter_column", "filter_value",
                         "sort_column", "ascending", "limit"]:
                build_config[field]["show"] = False

            # Show relevant fields
            if field_value == "filter":
                build_config["filter_column"]["show"] = True
                build_config["filter_value"]["show"] = True
            elif field_value == "sort":
                build_config["sort_column"]["show"] = True
                build_config["ascending"]["show"] = True
            elif field_value == "limit":
                build_config["limit"]["show"] = True

        return build_config

    def process(self) -> DataFrame:
        # Convert input to DataFrame
        if isinstance(self.data_input, DataFrame):
            df = self.data_input
        elif isinstance(self.data_input, Data):
            df = DataFrame([self.data_input.data])
        else:
            raise ValueError("Invalid input type")

        # Apply operation
        if self.operation == "filter":
            df = df[df[self.filter_column] == self.filter_value]
            self.status = f"Filtered to {len(df)} rows"

        elif self.operation == "sort":
            df = df.sort_values(self.sort_column, ascending=self.ascending)
            self.status = f"Sorted by {self.sort_column}"

        elif self.operation == "limit":
            df = df.head(self.limit)
            self.status = f"Limited to {len(df)} rows"

        return DataFrame(df)
```

## Contributing Components

To contribute to Langflow:

1. Fork the repository
2. Create component in appropriate category
3. Add tests in `tests/unit/`
4. Update documentation
5. Submit pull request

See: https://docs.langflow.org/contributing-components
