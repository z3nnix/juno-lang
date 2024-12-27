<div align="center" style="display:grid;place-items:center;">
<p>
    <a href="https://github.com/z3nnix/juno-lang"><img width="80" src="https://raw.githubusercontent.com/z3nnix/juno-lang/main/juno-logo.png" alt="Juno logo"></a>
</p>
<h1>The Juno Programming Language</h1>

[Docs](https://github.com/z3nnix/juno-lang/blob/main/docs.md)
| [Changelog](https://github.com/z3nnix/juno-lang/blob/main/CHANGELOG.md)
| [Speed](https://github.com/z3nnix/juno-lang/blob/main/BENCHMARK.md)
| [Contributing](https://github.com/z3nnix/juno-lang/blob/main/CONTRIBUTING.md)
<br><br>
This repository contains the Juno compiler, Juno's standard library, tools, and documentation.
</div>

> [!IMPORTANT]
> The current implementation of the compiler is not final. Juno aims to be self-hosting, meaning the current Ruby implementation will eventually be replaced by a compiler written in Juno itself.

## Why Juno?

- **Simple Syntax**: Juno provides a clean and intuitive syntax, making it easy to write and understand code, even for beginners.

- **High Speed**: Optimized for performance, Juno delivers lightning-fast execution, rivaling native solutions.

- **Cross-Compilation**: Seamlessly compile your code to run across multiple platforms, ensuring flexibility and portability.

## Juno Setup

To set up Juno, ensure you have the following dependencies installed:

### Dependencies

- **Ruby v3.2.3**
  - Install from the [official repository](https://github.com/ruby/ruby).
  - Verify installation:
    ```bash
    ruby --version
    ```

- **Tiny C Compiler (tcc) v0.9.27**
  - Download from the [official repository](https://github.com/Tiny-C-Compiler).
  - Build and install:
    ```bash
    ./configure
    make
    sudo make install
    ```
  - Verify installation:
    ```bash
    tcc --version
    ```

### Final Steps

After ensuring these dependencies are installed, you're ready to work with Juno. If additional steps are required, refer to the [official Juno documentation](https://github.com/z3nnix/juno-lang/blob/main/docs.md).

🎉 **Setup is complete!**

### Examples

📜 Examples can be found in the `examples/`[*](https://github.com/z3nnix/juno-lang/tree/main/examples) directory.