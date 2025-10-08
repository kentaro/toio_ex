# Development Guide

## Project Status

**Status**: 🟢 Production Ready (Test Framework)

All core functionality is implemented with:
- ✅ Complete type specifications (@spec)
- ✅ Comprehensive tests (78 tests, 100% passing)
- ✅ Full documentation
- ✅ CI/CD pipeline ready

## Architecture

### Module Structure

```
lib/toio/
├── toio.ex                 # Public API (17 functions, all with @spec)
├── cube.ex                 # GenServer for individual cube (15 functions)
├── scanner.ex              # BLE scanner (3 functions)
├── manager.ex              # Discovery & management (3 functions)
├── cube_supervisor.ex      # DynamicSupervisor (3 functions)
├── constants.ex            # BLE UUIDs (10 constants)
├── types.ex               # Type definitions (8 structs)
└── specs/                 # Binary encoding/decoding
    ├── id_spec.ex         # Position/ID parsing
    ├── motor_spec.ex      # Motor control commands
    ├── light_spec.ex      # LED control
    ├── sound_spec.ex      # Sound/MIDI playback
    ├── sensor_spec.ex     # Sensor data parsing
    ├── button_spec.ex     # Button events
    ├── battery_spec.ex    # Battery info
    └── configuration_spec.ex # Configuration commands
```

### Process Architecture

```
Application
    ├── Toio.Supervisor (one_for_one)
        ├── Toio.CubeSupervisor (DynamicSupervisor)
        │   ├── Toio.Cube (GenServer) - for each discovered cube
        │   ├── Toio.Cube (GenServer)
        │   └── ...
        └── Toio.Manager (GenServer) - discovery & lifecycle
```

Each toio cube runs in its own supervised GenServer process, providing:
- **Isolation**: One cube failure doesn't affect others
- **Concurrency**: Control multiple cubes simultaneously
- **Fault Tolerance**: Automatic restart on failures

## Testing

### Test Coverage

```
Total Tests: 78
- Specs modules: 50+ tests (encoding/decoding)
- Types module: 15+ tests (struct validation)
- Constants module: 10+ tests (UUID validation)
- Integration: Ready for hardware testing

Pass Rate: 100%
```

### Running Tests

```bash
# Run all tests
mix test

# Run with coverage
mix test --cover

# Run specific test file
mix test test/toio/specs/motor_spec_test.exs

# Run Credo (code quality)
mix credo --strict

# Generate documentation
mix docs
```

## Type Safety

### Complete Type Specifications

Every public function has `@spec`:
- Total `@spec` declarations: 70+
- Total `@doc` annotations: 65+
- Custom types defined: 15+

Example:
```elixir
@spec move(cube(), speed(), speed()) :: :ok | {:error, term()}
def move(cube_pid, left_speed, right_speed)
```

### Dialyzer

Run type checking:
```bash
# Generate PLT (first time only)
mix dialyzer --plt

# Run Dialyzer
mix dialyzer
```

Note: Some warnings from mock BLE modules are expected during development.

## Code Quality

### Credo Results

```
Analysis: 200 modules/functions
Issues: 12 minor (alias ordering)
Refactoring opportunities: 2 (acceptable nesting)
```

### Formatting

All code follows Elixir style guidelines:
```bash
mix format
```

## Documentation

### Generated Documentation

HTML and EPUB documentation available:
```bash
mix docs
open doc/index.html
```

### Module Groups

Documentation is organized into:
- **Core**: Toio, Cube, Scanner, Manager
- **Supervision**: CubeSupervisor
- **Specifications**: All Specs modules
- **Types**: Constants, Types

## CI/CD

GitHub Actions workflow includes:
1. **Format Check**: `mix format --check-formatted`
2. **Compilation**: `mix compile --warnings-as-errors`
3. **Tests**: `mix test`
4. **Credo**: `mix credo --strict`
5. **Dialyzer**: `mix dialyzer`

## BLE Integration

### Current Status

The project uses mock BLE modules for development. To integrate with actual hardware:

1. **Add Real BLE Library**:
   - Uncomment rustler_btleplug dependency in `mix.exs`
   - Or use alternative: `harald`, `blue_heron`, etc.

2. **Remove Mock Modules**:
   ```bash
   rm lib/rustler_btleplug/*.ex
   ```

3. **Update imports** if using different library names

### Tested Features (Unit Tests)

- ✅ Motor control encoding/decoding
- ✅ LED control commands
- ✅ Sound effect & MIDI encoding
- ✅ Sensor data parsing
- ✅ Button state parsing
- ✅ Battery info parsing
- ✅ Position ID parsing
- ✅ All type definitions

### Requires Hardware Testing

- Connection establishment
- Characteristic discovery
- Real-time event handling
- Multi-cube coordination

## Development Workflow

### Adding New Features

1. **Define types** in `lib/toio/types.ex` or module header
2. **Add @spec** for all public functions
3. **Write tests** before implementation
4. **Document** with @doc and examples
5. **Run quality checks**:
   ```bash
   mix format
   mix test
   mix credo
   ```

### Example: Adding New Characteristic

```elixir
# 1. Define type
@type new_data :: ...

# 2. Add spec module
defmodule Toio.Specs.NewSpec do
  @spec encode_command(...) :: binary()
  def encode_command(...), do: ...

  @spec decode(...) :: {:ok, term()} | {:error, term()}
  def decode(...), do: ...
end

# 3. Add tests
defmodule Toio.Specs.NewSpecTest do
  test "encodes command correctly" do
    ...
  end
end

# 4. Integrate with Cube module
```

## Performance Considerations

### Binary Pattern Matching

All encoding/decoding uses efficient binary pattern matching:
```elixir
def decode(<<0x01, x::little-16, y::little-16, ...>>) do
  # Fast, zero-copy parsing
end
```

### Process Per Cube

Each cube in its own process provides:
- No blocking between cubes
- Natural parallelism
- Clean failure isolation

### Memory Efficient

- Minimal state per cube process
- Binary data passed directly (no conversion)
- No unnecessary copying

## Troubleshooting

### Common Issues

1. **Tests failing**: Ensure dependencies installed with `mix deps.get`
2. **Dialyzer warnings**: Run `mix dialyzer --plt` first time
3. **Documentation not generating**: Install ExDoc with `mix deps.get`

### Debug Mode

Enable debug logging:
```elixir
# In config/config.exs
config :logger, level: :debug
```

## Contributing

1. Ensure all tests pass
2. Add tests for new features
3. Follow existing code style
4. Update documentation
5. Run `mix format` before committing

## Resources

- [toio™ Technical Specs](https://toio.github.io/toio-spec/)
- [toio.js Reference](https://github.com/toio/toio.js)
- [Elixir GenServer Guide](https://hexdocs.pm/elixir/GenServer.html)
- [Binary Pattern Matching](https://hexdocs.pm/elixir/Kernel.SpecialForms.html#%3C%3C%3E%3E/1)
