<!-- KEYWORDS: 01-Edu, Zone01, 42 Network, Piscine, Moulinette, Go-Piscine, Shell Quest, Local Tester -->

# Piscine Simulator For 01-Edu (Local Edition) 🚀

The Piscine Simulator is a local Command Line Interface (CLI) tool designed to help students of the **Learn to Earn / Zone01 / 42 Network** solidify their learning during and after the Piscine trials.

---

## 🛠 Installation & Setup

### 1. Clone the Simulator

Clone this repository to your machine. This folder will serve as your **Master Workspace**.

```bash
git clone https://github.com/EdenianKnight/piscine-simulator.git
cd piscine-simulator
```

### 2. Run the Setup Script

The setup script will remove the simulator's `.git` folder (making it your own private workspace), set permissions, and install the `checker` command to your system path:

```bash
chmod +x setup.sh
./setup.sh
```

> **Note:** This script will prompt for your `sudo` password to install the command system-wide.

---

## 📂 Setting Up Your Code (`piscine-go`)

The simulator expects your work to be inside a folder named `piscine-go`.

### Repository Workflow

If you want to save your progress, clone your personal `piscine-go` repository inside the `piscine-simulator` folder. Because the simulator's `.git` was removed during setup, your repo will be the only one active. You can `git push` your work normally.

---

## 📂 Workspace Structure

For the simulator to work, you must follow the folder naming rules provided by the Piscine instructions.

```sql
piscine-simulator/
├── .gitignore                  # Prevents student work from being tracked by Git
├── README.md                   # Project documentation
├── setup.sh                    # One-click installer (Permissions + System Symlink)
├── checker                     # Root gateway (points the system to the engine)
│
├── .piscine-grader/            # INTERNAL: The Simulation Engine
│   └── simulate.sh             # The "Brain" (Sandboxing, Path Discovery, Logic)
│
├── .01-edu-tests/              # INTERNAL: Hidden Test Data & Official Solutions
│   ├── quest01/                # Shell/Linux Quests
│   │   └── sh/
│   │       └── tests/
│   │           ├── solutions/  # Correct .sh scripts for comparison
│   │           └── [ex]_test.sh  # Official 01-Edu test logic
│   │
│   └── go-tests/               # Go Quests (Quest 02 and beyond)
│       ├── solutions/          # Official Go "Truth" (files or directories)
│       ├── tests/              # Official main.go files to test functions
│       └── lib/                # 01-Edu Go libraries (challenge, random, etc.)
│
└── piscine-go/                 # LOCAL WORKSPACE: Where you write your code
    ├── who-are-you/            # Shell Exercise Folder
    │   ├── who-are-you.sh      # Your solution
    │   └── trace.txt           # Generated automatically on failure
    │
    ├── printalphabet/          # Go Program Folder
    │   └── main.go             # package main (Full program)
    │
    └── isnegative/             # Go Function Folder
        ├── isnegative.go       # package piscine (The library function)
        └── main.go             # package main (The "Usage" code to test it)
```

---

## 🚀 How to Use

Run the checker from anywhere (inside the simulator root or deep inside an exercise folder).

### Basic Syntax

```bash
checker <exercise_name>
```

---

## 💡 Important: Go Package Management

Go does not allow two different packages (`main` and `piscine`) in the same folder. This often causes red lines in your IDE (VS Code).

### 1. Local Testing Phase

While coding and testing with the simulator:

- **The Function:** Write your function (e.g., `isnegative.go`) as `package piscine`.
- **The Test:** Write your test file (`main.go`) as `package main` and include `import "piscine"`.
- **IDE Error:** Your IDE will show a red error saying *"found packages piscine and main"*. **Ignore this error.**
- **Simulator Logic:** When you run `checker`, the simulator performs "surgery" in a temporary sandbox. It forces both files to `package main` and removes the `import "piscine"` so they can compile together perfectly.

### 2. Submission Phase (Before you `git push`)

The real 01-Edu/Zone01 server is strict. Before you push your code to the real trial repository, follow these rules:

| File Type | Local Testing (Checker) | Real Trial (Push) |
| --- | --- | --- |
| Function File | `package piscine` | `package piscine` |
| Program File | `package main` | `package main` |
| Test File (`main.go`) | Keep for testing | **Delete or do not push** |

> ⚠️ **WARNING:** Most function exercises in the real Piscine will **FAIL** if you include a `main.go` file or if your function is labeled `package main`. Ensure your function file is `package piscine` before your final push.

---

## 💡 Shell Exercises (Quest 01)

For Quest 01, the simulator provides a **mock API**. Use `curl` and `jq` as instructed in the subject. The simulator "intercepts" your `curl` calls and provides the correct mock data.

---

## 🔍 Debugging with Traces

If your code fails, a `trace.txt` file will be created inside your specific exercise folder (e.g., `piscine-go/isnegative/trace.txt`). This contains the full compiler error or the **"Expected vs Got"** output mismatch.

---

## ⚠️ Disclaimer

This simulator is a learning aid. Passing locally does **not** guarantee a 100% score on the official server. Always follow the Norm and double-check your folder names before final submission!
