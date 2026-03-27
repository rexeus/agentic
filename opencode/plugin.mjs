import {
  extractFilePath,
  extractWriteContent,
  findSecretViolations,
  getConventionWarningsForFile,
  validateConventionalCommitCommand,
} from "./guardrails.mjs";

const AgenticPlugin = async () => ({
  name: "agentic",

  "tool.execute.before": async (input, output) => {
    if (input.tool === "write" || input.tool === "edit") {
      const filePath = extractFilePath(output.args);
      const content = extractWriteContent(output.args);
      const violations = findSecretViolations({ filePath, content });
      if (violations.length > 0) {
        throw new Error(violations.join("\n"));
      }
      return;
    }

    if (input.tool === "bash") {
      const command = output?.args?.command;
      if (typeof command !== "string" || command.length === 0) {
        return;
      }

      const issues = validateConventionalCommitCommand(command);
      if (issues.length > 0) {
        throw new Error(`Commit message validation failed:\n${issues.join("\n")}`);
      }
    }
  },

  "tool.execute.after": async (input, output) => {
    if (input.tool !== "write" && input.tool !== "edit") {
      return;
    }

    const filePath = extractFilePath(input.args);
    const warnings = getConventionWarningsForFile(filePath);

    if (warnings.length === 0) {
      return;
    }

    const warningText = `[agentic warnings]\n${warnings.map((warning) => `- ${warning}`).join("\n")}`;
    output.output = output.output ? `${output.output}\n\n${warningText}` : warningText;
  },
});

export default AgenticPlugin;
