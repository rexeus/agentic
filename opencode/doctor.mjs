import { getDoctorStatus, getOpenCodeConfigDir, readOpenCodeConfig } from "./config.mjs";

export const doctorOpenCode = async () => {
  const configDir = getOpenCodeConfigDir();
  const { configPath, config, error } = readOpenCodeConfig(configDir);
  const status = await getDoctorStatus(configDir, config ?? {});

  return { configPath, configError: error, ...status };
};
