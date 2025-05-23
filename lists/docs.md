## .list File Format

This document describes the format for `.list` files, which are used to define operations for managing files and directories, typically configurations or dotfiles. These files are processed by accompanying shell scripts (`list.sh`, `list_functions.sh`).

Lines starting with `#` in an actual `.list` file are typically ignored as comments.

---

### Line Structure

Each operational line in a `.list` file consists of fields separated by a pipe character (`|`). The general structure is:

`Type|Source_Path|Target_Path|Target_Item|Dependency`

**Fields:**

1.  `Type`
2.  `Source_Path`
3.  `Target_Path`
4.  `Target_Item`
5.  `Dependency` (Optional)

---

### Field Descriptions

1.  **`Type`** (**Required**)
    * A single uppercase letter specifying the action to perform.
    * Possible values:
        * **`B`**: **Backup**
            * Creates a backup of the `Source_Path/Target_Item` into a predefined `$BACKUP_DIR`.
            * For **files**, the original directory structure leading to the file is replicated within `$BACKUP_DIR` (e.g., if source is `/path/to/file.txt`, backup is `$BACKUP_DIR/path/to/file.txt`).
            * For **directories**, the source directory itself (e.g., `my_dir`) is copied directly into `$BACKUP_DIR` (e.g., `$BACKUP_DIR/my_dir`), not its full original path structure.
        * **`S`**: **Sync**
            * First, performs a **Backup** operation on `Source_Path/Target_Item`.
            * Then, synchronizes `Source_Path/Target_Item` with `Target_Path/Target_Item`. The target is updated only if its content differs from the source.
        * **`O`**: **Overwrite**
            * First, performs a **Backup** operation on `Source_Path/Target_Item`.
            * Then, forcibly copies `Source_Path/Target_Item` to `Target_Path/Target_Item`, overwriting the destination if it exists.
        * **`P`**: **Populate**
            * First, performs a **Backup** operation on `Source_Path/Target_Item`.
            * Then, copies `Source_Path/Target_Item` to `Target_Path/Target_Item` **only if** the destination (`Target_Path/Target_Item`) does not already exist. This is useful for initial setup.

2.  **`Source_Path`** (**Required**)
    * The base directory path where the source `Target_Item` is located.
    * This path can contain environment variables (e.g., `${HOME}`, or relative paths like `./rice`).
    * *Example:* `./rice/home/user/.config`

3.  **`Target_Path`** (**Required**)
    * The base directory path where the `Target_Item` should be placed, synchronized with, or checked against.
    * This path can also contain environment variables.
    * *Example:* `${HOME}/.config`

4.  **`Target_Item`** (**Required**)
    * The name of the specific file or directory to be acted upon. This name is appended to both `Source_Path` and `Target_Path` to determine the full source and target paths.
    * *Example:* `hypr` (This would make the full source path `./rice/home/user/.config/hypr` and the full target path `${HOME}/.config/hypr` based on the example paths above).

5.  **`Dependency`** (**Optional**)
    * The name of a software package or command that must be installed or present for this line's operation to be attempted.
    * If the dependency (as checked by an `is_pkg_installed` function in the processing scripts) is not met, the operation for this line will be skipped.
    * If no dependency is needed, this field can be left empty (i.e., `Type|Source|Target|Item|`).
    * *Example:* `hyprland`

---

### Example

```sh
S|./rice/home/user/.config|${HOME}/.config|hypr|hyprland
```

* **Type:** `S` (Sync)
* **Source_Path:** `./rice/home/user/.config`
* **Target_Path:** `${HOME}/.config`
* **Target_Item:** `hypr`
* **Dependency:** `hyprland`
* **Operation:** If the `hyprland` package is installed, this line will first back up `./rice/home/user/.config/hypr` and then synchronize its contents with `${HOME}/.config/hypr`.