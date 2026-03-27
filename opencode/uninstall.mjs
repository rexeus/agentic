import { existsSync } from "node:fs";

import {
  backupConfigFile,
  getDoctorStatus,
  getOpenCodeConfigDir,
  readOpenCodeConfig,
  removePluginEntry,
  uninstallGlobalAgents,
  uninstallGlobalCommands,
  uninstallGlobalSkills,
  validateOpenCodeConfigForMutation,
  writeOpenCodeConfig,
} from "./config.mjs";

export const uninstallOpenCode = async () => {
  const configDir = getOpenCodeConfigDir();
  const { configPath, config, error } = readOpenCodeConfig(configDir);

  if (error) {
    throw new Error(error);
  }

  const mutationError = validateOpenCodeConfigForMutation(configPath, config);
  if (mutationError) {
    throw new Error(mutationError);
  }

  const installStatus = await getDoctorStatus(configDir, config);
  const hasManagedAssets =
    installStatus.commands.installedFiles.length > 0 ||
    installStatus.agents.installedFiles.length > 0 ||
    installStatus.skills.installedFiles.length > 0;

  if (!installStatus.pluginSources.config && !hasManagedAssets) {
    return {
      configPath,
      backupPath: null,
      removedCommands: 0,
      removedAgents: 0,
      removedSkills: 0,
    };
  }

  const updated = removePluginEntry(config);
  const hasConfigFile = existsSync(configPath);

  const backupPath = hasConfigFile ? await backupConfigFile(configPath) : null;

  if (hasConfigFile) {
    await writeOpenCodeConfig(configPath, updated);
  }
  const removedCommands = await uninstallGlobalCommands(configDir);
  const removedAgents = await uninstallGlobalAgents(configDir);
  const removedSkills = await uninstallGlobalSkills(configDir);

  return {
    configPath,
    backupPath,
    removedCommands,
    removedAgents,
    removedSkills,
  };
};
