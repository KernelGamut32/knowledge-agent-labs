# A very small C# agent with Foundry Local

**30-minute core lab | Optional 20-minute sentiment exercise | Separate 5-minute cloud-switch demonstration**

Build and customize one .NET 10 console agent. It has one read-only C# tool that queries fictional Lighthouse Credit Union support information in a small local SQLite database. The model chooses whether to call the tool; the console makes that call visible. The same agent can use an Azure-hosted model after a configuration change and restart.

Start with the local lab. Azure access is needed only for the optional instructor demonstration. SQLite runs inside the app and stores the knowledge in one local file. NuGet restores the required library, so there is no database server or separate database installer. The package needs no Docker, Codespaces, or web application.

## What you need

- A workshop computer with Windows 11 24H2 or later and software-install permission. A compatible CPU model is sufficient; dedicated AI hardware is not required.
- The .NET 10 SDK, Foundry Local CLI, a terminal, and a text editor such as Visual Studio Code.
- Internet for the initial SDK, NuGet, execution-provider, and model downloads. Prepare these before the timed lab.

This Windows version is the workshop baseline. Model availability and speed depend on the device. The optional Apple silicon Mac path is below. Product references and verification limits are in [Sources and Validation](Sources_and_Validation.md).

## 1. Install once

In PowerShell:

```powershell
winget install Microsoft.DotNet.SDK.10
winget install Microsoft.FoundryLocal
```

Open a **new PowerShell window** so the installed commands are on PATH. Verify that the SDK list includes 10.x and that the current Foundry help includes the `server` command group:

```powershell
dotnet --list-sdks
foundry --version
foundry --help
```

## 2. Prepare one small model

```powershell
foundry server start --port 39839 --idle-timeout 0
foundry model list
foundry model info qwen3-v1-2b-instruct
foundry model download qwen3-v1-2b-instruct
foundry model load qwen3-v1-2b-instruct
foundry server status
```

Use the `qwen3-v1-2b-instruct` alias from Microsoft's current tool-calling example. Confirm its applicable catalog variant supports the `tools` task. The alias lets Foundry choose a compatible hardware variant. Keep **exactly one model loaded** for this simple app. The app discovers its actual runtime ID.

Confirm that server status reports port **39839**. If your own existing Foundry server is using another port, restart it at the lab port and reload the model:

```powershell
foundry server restart --port 39839 --idle-timeout 0
foundry model load qwen3-v1-2b-instruct
```

Restarting affects models in that local server. Finish any other local Foundry work first. The zero idle timeout keeps the server running; a model can still unload separately. Reload it if the app reports that no model is loaded.

## 3. Run the supplied C# project

Extract this updated package into a fresh folder and open a terminal in the `Foundry_Local_Simple_Agent` folder. Then run:

```powershell
cd App
dotnet restore
dotnet run -- --show-knowledge
dotnet run
```

The first command that opens the knowledge store creates `support.db` from `seed.sql` if the database is missing. The inspection command prints the database's absolute path and its 12 articles, then exits without calling a model. It displays the queried rows as JSON for readability. The database is stored next to the built executable and persists across normal runs.

The normal run selects **Local** by default and shows the same database path. Ask:

```text
Use your support information tool to tell me Member Care's Saturday hours and time zone.
```

Look for this tool-call marker:

```text
[tool] get_support_info -> querying SQLite support.db
```

Compare the answer with the inspected rows. The fictional Saturday hours are 09:00 to 13:00 in America/New_York. An answer without the expected tool trace does not demonstrate tool execution.

Continue with the [Hands-on Lab](Lab_Guide.md). The complete working core code is supplied so learners can focus on the agent loop and two small edits. Use [Test Prompts](Test_Prompts.md) to choose additional checks against the expanded knowledge. Afterward, complete the optional [Sentiment Tool Exercise](Sentiment_Tool_Exercise.md) to add a second tool.

## How the small knowledge store works

`knowledge_articles` has three columns: `article_id`, `title`, and `content`. Its 12 rows cover Member Care, Card Security, digital sign-in, mobile deposits and review, internal transfers, statements, appointments, accessibility, complaint follow-up, agent capabilities, and the fictional-data notice. The model can request `get_support_info`; C# then uses a fixed `SELECT` through a read-only connection to retrieve those rows. The model supplies neither SQL nor a file path.

**The database is the source of truth during normal runs.** Editing `seed.sql` alone does not change an existing database. The lab shows you how to edit the Saturday hours and explicitly reload the synthetic knowledge:

```powershell
dotnet run -- --reset-db
dotnet run -- --show-knowledge
```

Run these from `App`, after exiting the agent. Reset replaces the lab's `knowledge_articles` table using `seed.sql`; it is a deliberate learner command, not a tool the model can call. Both commands work without a running model or Azure credentials. The [Lab Guide](Lab_Guide.md) includes the complete change-and-restore exercise.

## Updating an earlier copy

If your working folder already has the previous four-article database, normal startup preserves it. After updating the source files, exit the agent and run these commands from `App` to load and inspect the expanded fictional dataset:

```powershell
dotnet run -- --reset-db
dotnet run -- --show-knowledge
```

Reset replaces the synthetic knowledge table with the 12 articles in the current seed. It does not update an existing conversation; start a new app session for the next test.

## Optional second tool: sentiment analysis

The core app has one tool. The follow-up guide walks you through adding `analyze_sentiment`, which classifies the current incoming request as **positive**, **negative**, or **neutral** using the same configured model in an isolated request. It adds no service, credential, or NuGet package. A valid label is shown separately from the support answer. A missing call or invalid result is reported as unavailable, never silently changed to neutral.

The completed source is supplied under `Solutions/Sentiment` for comparison or recovery. That folder is outside `App` and is not part of the core build. Follow the exercise's copy-and-edit steps to install it. The extra model request can add latency and, when using Azure, inference cost. Sentiment is a text classification exercise; it does not authorize an account action or determine security routing.

## Files you will use

| File | Purpose |
|---|---|
| `App/Program.cs` | Agent instructions, tool definition, command handling, and conversation loop |
| `App/KnowledgeStore.cs` | Creates, inspects, and explicitly resets the SQLite store; runs the tool's fixed read-only query |
| `App/appsettings.json` | Local or Azure provider selection and endpoints |
| `App/seed.sql` | Table definition and fictional articles used for initial creation or an explicit reset |
| `support.db` (generated) | Local SQLite database next to the built executable; the app prints its absolute path |
| `App/*.csproj` | .NET 10 console project with pinned OpenAI and Microsoft.Data.Sqlite package dependencies |
| [Lab Guide](Lab_Guide.md) | Timed learner activities and five outcome checks |
| [Test Prompts](Test_Prompts.md) | 16 core checks, nine sentiment checks, expected evidence, and two optional stress probes |
| [Sentiment Tool Exercise](Sentiment_Tool_Exercise.md) | Optional guided C# changes to add the second tool |
| `Solutions/Sentiment/` | Completed follow-up source for comparison or recovery |
| [Cloud Switch Demo](Cloud_Switch_Demo.md) | Instructor's optional configuration-switch demonstration |
| [Sources and Validation](Sources_and_Validation.md) | Current primary references and what was actually tested |

Lighthouse names, contact details, and service rules are fictional. They do not represent SchoolsFirst Federal Credit Union policy. The phone numbers are nonworking training placeholders. Use no real member information.

## Apple silicon Mac option

Install the .NET 10 **Arm64 SDK** using Microsoft's [macOS instructions](https://learn.microsoft.com/en-us/dotnet/core/install/macos). Install Foundry Local with:

```bash
brew tap microsoft/foundrylocal
brew install foundrylocal
```

Then use the same `foundry` and `dotnet` commands above in Terminal. This package does not promise Intel Mac support. The cloud demo's main secret-entry commands are for PowerShell; it also supplies a Bash alternative.

## Quick fixes

| Symptom | Smallest useful next step |
|---|---|
| `dotnet` or `foundry` is not found | Open a new terminal and verify installation |
| The `server` command is unknown | Check the installed CLI version against current Learn; update the CLI before class |
| Connection refused | Check `foundry server status` and the configured local port |
| No loaded model | Run `foundry model load qwen2.5-0.5b` again |
| More than one loaded model | Inspect `foundry model list --loaded` and unload an unneeded model by its actual ID |
| Model answers without a tool call | Start a fresh conversation, use the explicit first prompt, and check the variant's tools capability |
| A reply is incomplete or repeatedly requests a tool | Record the result; reset and retry once. Rehearse a suitable model on the delivery device before class |
| Edited seed but the database still has old hours | Exit the agent, run `dotnet run -- --reset-db` from `App`, then inspect with `dotnet run -- --show-knowledge` |
| Invalid seed, missing table, or empty knowledge | Exit the agent, fix `seed.sql`, and run `dotnet run -- --reset-db` from `App`. A failed first creation can leave a database file that needs this explicit reset. |
| Unsure which database the app uses | Read `Knowledge database:` in the startup banner or inspection output; it shows the absolute path |
| Azure configuration fails | Use the resource inference endpoint and deployment name in the demo guide; keep Provider Local for the core lab |

If a reset fails against an existing database, its transaction rolls back and preserves the previous table. Correct the seed before retrying. Inside the chat, `/reset` clears only the conversation; the terminal option `--reset-db` reloads the synthetic knowledge.

At the end, exit the app. If you no longer need your local Foundry server, `foundry server stop` stops it. Downloaded model files stay cached for the next session.
