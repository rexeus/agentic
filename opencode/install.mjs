import {
  backupConfigFile,
  ensureOpenCodeConfigDir,
  ensurePluginEntry,
  getDoctorStatus,
  installGlobalAgents,
  installGlobalCommands,
  installGlobalSkills,
  readOpenCodeConfig,
  validateOpenCodeConfigForMutation,
  writeOpenCodeConfig,
} from "./config.mjs";

export const installOpenCode = async () => {
  const configDir = ensureOpenCodeConfigDir();
  const { configPath, config, error } = readOpenCodeConfig(configDir);

  if (error) {
    throw new Error(error);
  }

  const mutationError = validateOpenCodeConfigForMutation(configPath, config);
  if (mutationError) {
    throw new Error(mutationError);
  }

  const backupPath = await backupConfigFile(configPath);
  const updated = ensurePluginEntry(config);

  await writeOpenCodeConfig(configPath, updated);
  const commandsDir = await installGlobalCommands(configDir);
  const agentsDir = await installGlobalAgents(configDir);
  const skillsDir = await installGlobalSkills(configDir);
  const status = await getDoctorStatus(configDir, updated);

  return {
    configPath,
    backupPath,
    commandsDir,
    agentsDir,
    skillsDir,
    conflicts: {
      commands: status.conflictingCommands,
      agents: status.conflictingAgents,
      skills: status.conflictingSkills,
    },
  };
};
