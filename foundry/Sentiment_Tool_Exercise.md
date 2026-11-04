# Follow-up exercise: add a sentiment tool in C#

**Duration:** about 20 minutes after the 30-minute core lab.  
**Outcome:** add a second tool that classifies the current request as **positive**, **negative**, or **neutral**.  
**Environment:** the same .NET 10 project, configured model, and Local or Azure settings. No additional SDK, model download, or service is required.

Keep your terminal in the **`App` folder**. Complete the core lab first and confirm that the SQLite support tool works. Use `Provider: Local` for this exercise; the instructor can rehearse the completed extension with the optional cloud configuration later.

You will copy a small classifier class, then edit the working agent to register and execute its new tool. The completed [Program.cs reference](Solutions/Sentiment/Program.cs) is available if you need help recovering an edit.

## What the second tool does

The agent model chooses whether to request `analyze_sentiment`. The tool takes **no arguments**. Your C# code supplies the exact latest user input to a separate classification request using the same `ChatClient`. That request contains a classification prompt and the current input, with no earlier conversation or tool definitions. C# accepts only the three permitted labels and reports an unavailable result when classification fails or returns an invalid response.

This is model-backed classification. The model interprets the text; C# validates its output. The existing `get_support_info` tool continues to obtain support facts through its fixed, read-only SQLite query.

### The lab's classification rubric

| Label | Meaning in this exercise |
|---|---|
| `positive` | Appreciation, satisfaction, or praise without an unresolved complaint |
| `negative` | Frustration, dissatisfaction, worry, or an unresolved negative experience |
| `neutral` | A factual request without a clear opinion |

For a message that mixes thanks or praise with an unresolved complaint or worry, this lab uses **negative**. These definitions are teaching choices, and a label is an interpretation of the message's wording. It does not establish a person's actual feelings or determine security urgency. Support routing still comes from the request and the knowledge articles; neither tool can perform account actions.

## Activity 1: prepare the files | 3 minutes

1. Enter `/exit` if the agent is running.
2. Copy `App/Program.cs` in the same folder and name the copy **`Program.cs.before-sentiment`**. Keep an existing core backup if you already made one. Use this exact extension so the backup is not compiled as another C# source file.
3. Copy [Solutions/Sentiment/SentimentAnalyzer.cs](Solutions/Sentiment/SentimentAnalyzer.cs) into `App`, beside `Program.cs` and `KnowledgeStore.cs`.
4. Open your working `App/Program.cs`. Find the comments beginning `SENTIMENT`. They mark the edits below.

The SDK automatically includes the copied `.cs` file in the existing project. Keep the completed reference `Program.cs` in `Solutions` while you make your edits.

## Activity 2: connect the second tool | 9 minutes

### 1. Add its instruction

At **SENTIMENT 1**, insert this line inside the existing instruction string, immediately after the sentence that introduces Lighthouse Member Support:

```text
For every incoming request, call analyze_sentiment. Never invent a label if that tool is unavailable.
```

Keep the existing support-knowledge and capability instructions. You can retain the answer-style change from the core lab.

### 2. Register both tools

At **SENTIMENT 2**, replace the entire `var options = new ChatCompletionOptions` block, through its closing `};`, with:

```csharp
var options = new ChatCompletionOptions
{
    ToolChoice = ChatToolChoice.CreateAutoChoice(),
    MaxOutputTokenCount = 4096,
    Tools =
    {
        ChatTool.CreateFunctionTool("get_support_info",
            "Query local SQLite for Lighthouse support, policies and processes: login, deposits, transfers, statements, appointments, accessibility, complaints, hours, contacts and capability limits.",
            BinaryData.FromString("""{"type":"object","properties":{},"additionalProperties":false}""")),
        ChatTool.CreateFunctionTool("analyze_sentiment",
            "Classify the latest incoming request as positive, negative or neutral. The app supplies the original text; pass no arguments.",
            BinaryData.FromString("""{"type":"object","properties":{},"additionalProperties":false}"""))
    }
};
```

Both tools use an empty argument schema. The model can request classification, but C# controls which text is classified. `Auto` keeps tool selection with the model, so the runtime must also make a missing tool call visible.

### 3. Connect one classification result to each turn

At **SENTIMENT 3A**, add this line immediately after the comment, before `history.Add(new UserChatMessage(input));`:

```csharp
var sentiment = new SentimentAnalyzer(client, input);
```

Create it here, inside the input loop. A new instance holds each incoming request and caches that turn's classification result. Repeated requests for the tool during the same turn reuse the result.

At **SENTIMENT 3B**, replace the existing two-line `foreach` statement with:

```csharp
foreach (var call in completion.ToolCalls)
    history.Add(new ToolChatMessage(call.Id, await ExecuteToolAsync(call, sentiment, deadline.Token)));
```

The `await` allows classification to make its model request. `call.Id` still connects each tool result to the correct model request, and `deadline.Token` preserves the existing turn deadline.

At **SENTIMENT 3C**, add this `finally` block after the existing turn-level `catch` block and before the closing brace of the input loop:

```csharp
finally
{
    Console.WriteLine($"Sentiment: {sentiment.Display}\n");
}
```

There must be no executable statement between that `catch` block and `finally`; the marker comment can remain. This footer displays the C# result even when classification was not requested or a request failed.

### 4. Dispatch the two permitted tool names

At **SENTIMENT 4**, replace the complete `static string ExecuteTool(...)` function with:

```csharp
static async Task<string> ExecuteToolAsync(ChatToolCall call, SentimentAnalyzer sentiment, CancellationToken cancellationToken)
{
    if (call.FunctionName is not ("get_support_info" or "analyze_sentiment"))
        return """{"error":"Unknown tool. Only get_support_info and analyze_sentiment are available."}""";
    using var arguments = JsonDocument.Parse(call.FunctionArguments);
    if (arguments.RootElement.ValueKind != JsonValueKind.Object || arguments.RootElement.EnumerateObject().Any())
        return """{"error":"Both tools take no arguments. Use an empty JSON object."}""";
    return call.FunctionName == "get_support_info"
        ? GetSupportInfo()
        : await sentiment.AnalyzeAsync(cancellationToken);
}
```

Leave `GetSupportInfo()` in place. Update its nearby comment to `// LAB 2: This tool reads the SQLite knowledge.` The dispatcher now allows exactly two function names, validates their empty arguments, and selects the corresponding C# implementation.

Save your files and build from `App`:

```text
dotnet build
```

**Checkpoint:** point to the second tool definition, its dispatcher branch, and the line that captures the exact current input. In `SentimentAnalyzer.cs`, find the fresh two-message request, label validation, and cached result. The classifier does not receive the conversation history.

## Activity 3: demonstrate three labels | 5 minutes

Run the edited agent:

```text
dotnet run
```

Use these exact prompts from [Test Prompts](Test_Prompts.md). Enter `/reset` between the three independent cases. Each asks a support question, so require **both** the sentiment tool trace and the SQLite tool trace.

| Case | Input | Expected label | Support facts to check |
|---|---|---|---|
| S01 | Thanks for the clear help! What are Member Care's Saturday hours? | `positive` | Saturday 09:00 to 13:00, America/New_York |
| S05 | I am worried about a lost card. Which number should I use? | `negative` | Card Security, +1 614 555 0199, available 24 hours daily; number identified as a nonworking training placeholder |
| S07 | What are the mobile check deposit limits? | `neutral` | Eligible personal checking: $2,000 per check and $3,000 per day |

For S05, these are the **expected markers**, not a transcript of a preverified live run. The two tool traces may appear in either order:

```text
[tool] analyze_sentiment -> negative
[tool] get_support_info -> querying SQLite support.db
```

After the agent's answer, check the C# footer:

```text
Sentiment: negative
```

Score the actual tool trace and runtime footer. A sentiment label written only in the agent's prose does not prove that the classification tool ran. A correct label also does not prove that the support answer used the right facts.

## Activity 4: check isolation and explain the extra call | 3 minutes

Start a fresh conversation with `/reset`. Send **S05**, then send **S07 without resetting between them**. The second classification should be `neutral` under this rubric because its input is only the latest factual question. The earlier worried message stays in the support conversation but is excluded from the classifier's fresh request.

Complete these focused checks using your actual results:

| Check | Evidence required | Your result |
|---|---|---|
| Three labels | S01, S05, and S07 each produce the expected validated label and both tool traces | Not run |
| Facts remain grounded | Support answers agree with the SQLite articles and retain capability limits | Not run |
| Latest-message isolation | S07 remains neutral when it follows S05 without a reset | Not run |
| Failure visibility | Code accepts only the three labels; missing or invalid classification is reported as unavailable | Not run |

For the final row, inspect the code unless you actually encounter the failure. Record code inspection separately from an observed runtime failure. The remaining **S01-S09** cases and recording table are in [Test Prompts](Test_Prompts.md).

When invoked, the new tool adds a classification model call. Repeated sentiment-tool requests in that turn use the cached result and show `(cached)` in the trace. Classification adds latency; with `Provider: Azure`, it also adds cloud usage. Both the support-agent and classification requests use the configured endpoint and model. Rehearse the chosen cloud deployment separately because a prompt that works with the tiny local model can behave differently with another model.

**Explain:** Why does the tool accept no text argument? What would go wrong if we classified the whole conversation? Which additional model request is made when the tool runs?

## Focused troubleshooting

| Observation | Check or next step |
|---|---|
| Build cannot find `SentimentAnalyzer` | Put `SentimentAnalyzer.cs` directly in `App`, with the working `Program.cs`. |
| Build fails around `await`, `finally`, or `ExecuteTool` | Compare the matching SENTIMENT sections with the completed reference. Replace the old dispatcher, update its call site, and keep `finally` attached to the turn-level `try`/`catch`. |
| `Sentiment: unavailable (tool not called)` | The agent did not invoke the tool. Check its registration and instruction, reset, and retry the same prompt once. Record a continuing failure; this is not a successful classification. |
| `unavailable (invalid classifier output)` | The classifier did not finish normally with exactly one permitted label, or it attempted a tool call. Record the limitation and rehearse a compatible model. Do not convert this failure to `neutral`. |
| `unavailable (classifier request failed)` | Check model availability, the shared turn deadline, and, in Azure mode, access and quota. Retry a fresh turn after resolving the cause. |
| The label follows the previous message | Confirm the analyzer is created inside the input loop at SENTIMENT 3A and that its request contains only the rubric and current input. Then repeat the isolation check. |
| Correct label, wrong support answer | Check the SQLite trace and inspect the stored articles with `dotnet run -- --show-knowledge` after exiting the agent. Evaluate the two outcomes separately. |

After the timed exercise, optionally try negation, sarcasm, or a message mixing thanks with an unresolved complaint. Predict the label using the rubric, then compare the actual result. Small models can misread these cases. Keep the observed failure in your notes rather than treating a permitted label as proof of accurate interpretation.

## Recovery and restoration

If an edit blocks the exercise, exit the app and copy [Solutions/Sentiment/Program.cs](Solutions/Sentiment/Program.cs) **over** `App/Program.cs`. Ensure `SentimentAnalyzer.cs` is also in `App`, then run `dotnet build` and `dotnet run`. This reference replaces your instruction-style edits; your backup retains them. Use one working `Program.cs`, rather than saving the reference as another `.cs` file in the same project.

To restore your original core version, exit the app, copy `Program.cs.before-sentiment` over `Program.cs`, and remove the copied `App/SentimentAnalyzer.cs`. Run `dotnet run`. This returns the project to your backed-up core code and retains the existing database and configuration.

## Microsoft grounding and verification

The registration, model-requested function call, C# execution, and matching tool-result ID follow [Microsoft Learn's Foundry Local tool-calling guidance](https://learn.microsoft.com/en-us/azure/foundry-local/how-to/how-to-use-tool-calling-with-foundry-local). `Auto` leaves tool choice with the model, so a missing call remains an observable outcome.

The isolated classification request and three-label rubric are this exercise's implementation choices. They do not guarantee correct interpretation for every message or model. Use the supplied prompts to evaluate the actual workshop model. Package build checks, simulated integration checks, and live-inference limits are recorded in [Sources and Validation](Sources_and_Validation.md).
