#!/usr/bin/env node

import { doctorOpenCode } from "../opencode/doctor.mjs";
import { installOpenCode } from "../opencode/install.mjs";
import { uninstallOpenCode } from "../opencode/uninstall.mjs";

const printUsage = () => {
  console.log(`Usage:
  agentic install opencode
  agentic uninstall opencode
  agentic doctor`);
};

const fail = (message) => {
  console.error(`agentic: ${message}`);
  process.exit(1);
};

const printAssetDoctorStatus = (label, installedLabel, missingLabel, conflictLabel, status) => {
  console.log(`${label} dir: ${status.dir}`);
  console.log(`${label} present: ${status.presentFiles.length > 0 ? "yes" : "no"}`);

  if (status.missingFiles.length === 0 && status.conflictingFiles.length === 0) {
    console.log(`${installedLabel}: yes`);
    return;
  }

  console.log(
    `${installedLabel}: no (${status.conflictingFiles.length} conflicting, ${status.missingFiles.length} missing)`,
  );

  for (const fileName of status.conflictingFiles) {
    console.log(`- ${conflictLabel}: ${fileName}`);
  }

  for (const fileName of status.missingFiles) {
    console.log(`- ${missingLabel}: ${fileName}`);
  }
};

const run = async () => {
  const command = process.argv[2];
  const target = process.argv[3];

  if (command === "install") {
    if (target !== "opencode") {
      fail("expected target 'opencode'");
    }

    const result = await installOpenCode();
    console.log(`Installed OpenCode integration.`);
    console.log(`Config: ${result.configPath}`);
    if (result.backupPath) {
      console.log(`Backup: ${result.backupPath}`);
    }
    console.log(`Commands: ${result.commandsDir}`);
    console.log(`Agents: ${result.agentsDir}`);
    console.log(`Skills: ${result.skillsDir}`);
    if (
      result.conflicts.commands.length > 0 ||
      result.conflicts.agents.length > 0 ||
      result.conflicts.skills.length > 0
    ) {
      console.log("Conflicts detected with existing unowned OpenCode assets:");
      for (const commandName of result.conflicts.commands) {
        console.log(`- command conflict: ${commandName}`);
      }
      for (const agentName of result.conflicts.agents) {
        console.log(`- agent conflict: ${agentName}`);
      }
      for (const skillName of result.conflicts.skills) {
        console.log(`- skill conflict: ${skillName}`);
      }
    }
    return;
  }

  if (command === "uninstall") {
    if (target !== "opencode") {
      fail("expected target 'opencode'");
    }

    const result = await uninstallOpenCode();
    console.log(`Removed OpenCode integration.`);
    console.log(`Config: ${result.configPath}`);
    if (result.backupPath) {
      console.log(`Backup: ${result.backupPath}`);
    }
    console.log(`Removed commands: ${result.removedCommands}`);
    console.log(`Removed agents: ${result.removedAgents}`);
    console.log(`Removed skills: ${result.removedSkills}`);
    return;
  }

  if (command === "doctor") {
    const result = await doctorOpenCode();
    console.log("Agentic OpenCode Doctor");
    console.log(`Config: ${result.configPath}`);
    if (result.configError) {
      console.log(`Config valid: no`);
      console.log(`Config error: ${result.configError}`);
    } else {
      console.log(`Config valid: yes`);
    }
    console.log(`Plugin installed: ${result.pluginInstalled ? "yes" : "no"}`);
    console.log(`Plugin via config: ${result.pluginSources.config ? "yes" : "no"}`);
    console.log(`Plugin local files: ${result.pluginSources.localFiles.length}`);
    for (const pluginFile of result.pluginSources.localFiles) {
      console.log(`- plugin file: ${pluginFile}`);
    }
    printAssetDoctorStatus("Commands", "Commands installed", "missing", "command conflict", {
      dir: result.commandsDir,
      presentFiles: result.commands.presentFiles,
      conflictingFiles: result.commands.conflictingFiles,
      missingFiles: result.commands.missingFiles,
    });
    printAssetDoctorStatus("Agents", "Agents installed", "missing agent", "agent conflict", {
      dir: result.agentsDir,
      presentFiles: result.agents.presentFiles,
      conflictingFiles: result.agents.conflictingFiles,
      missingFiles: result.agents.missingFiles,
    });
    printAssetDoctorStatus("Skills", "Skills installed", "missing skill", "skill conflict", {
      dir: result.skillsDir,
      presentFiles: result.skills.presentFiles,
      conflictingFiles: result.skills.conflictingFiles,
      missingFiles: result.skills.missingFiles,
    });

    return;
  }

  printUsage();
  process.exit(1);
};

run().catch((error) => {
  fail(error instanceof Error ? error.message : String(error));
});
