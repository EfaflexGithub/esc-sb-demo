import 'package:efa_smartconnect_modbus_demo/modules/settings/models/setting_types.dart';
import 'package:flutter/material.dart';

enum AppSettingKeys {
  appDarkMode,
  eventHighlightingTime,
  eventHighlightingCycles,
  showUnknownUserApplications,
  defaultModbusTcpHostAddress,
  defaultModbusTcpPort,
  defaultModbusTcpTimeout,
  defaultModbusTcpRetryCount,
  defaultModbusTcpRefreshRate,
  defaultModbusTcpLicenseKey,
  notifyTimeTreshold,
  notifyErrorEvents,
  notifyWarningEvents,
  notifyInfoEvents,
}

final applicationSettings = ApplicationSettings<AppSettingKeys>(
  categories: [
    SettingsCategory(
      label: 'General',
      icon: Icons.apps,
      groups: [
        SettingsGroup(
          label: 'Appereance',
          settings: [
            Setting<AppSettingKeys, bool>(
              storageKey: AppSettingKeys.appDarkMode,
              title: 'Dark Mode',
              defaultValue: false,
            ),
          ],
        ),
      ],
    ),
    SettingsCategory(
      label: 'Door Overview',
      icon: Icons.home,
      groups: [
        SettingsGroup(
          label: 'Highlighting',
          settings: [
            Setting<AppSettingKeys, int>(
              storageKey: AppSettingKeys.eventHighlightingTime,
              title: 'Events by Hours',
              description: 'Highlight events that are younger than x hours.',
              defaultValue: 72,
            ),
            Setting<AppSettingKeys, int>(
              storageKey: AppSettingKeys.eventHighlightingCycles,
              title: 'Events by Cycles',
              description: 'Highlight events that are younger than x cycles.',
              defaultValue: 20,
            ),
          ],
        ),
        SettingsGroup(
          label: 'User Applications',
          settings: [
            Setting<AppSettingKeys, bool>(
              storageKey: AppSettingKeys.showUnknownUserApplications,
              title: 'Unknown User Applications',
              description:
                  'Show unknown user applications in the door overview',
              defaultValue: false,
            ),
          ],
        ),
      ],
    ),
    SettingsCategory(
      label: 'Modbus TCP',
      icon: Icons.lan,
      groups: [
        SettingsGroup(
          label: 'Prefill Values',
          settings: [
            Setting<AppSettingKeys, String>(
              storageKey: AppSettingKeys.defaultModbusTcpHostAddress,
              title: 'Host address',
              defaultValue: '127.0.0.1',
            ),
            Setting<AppSettingKeys, int>(
              storageKey: AppSettingKeys.defaultModbusTcpPort,
              title: 'Port',
              defaultValue: 502,
            ),
            Setting<AppSettingKeys, int>(
              storageKey: AppSettingKeys.defaultModbusTcpTimeout,
              title: 'Timeout',
              defaultValue: 1000,
            ),
            Setting<AppSettingKeys, int>(
              storageKey: AppSettingKeys.defaultModbusTcpRefreshRate,
              title: 'Refresh rate',
              defaultValue: 1000,
            ),
            Setting<AppSettingKeys, String>(
              storageKey: AppSettingKeys.defaultModbusTcpLicenseKey,
              title: 'License key',
              defaultValue: 'J6LC5-ALT3Q-7HMAB-YZ3GR-MPO7Z-CN33E',
            )
          ],
        ),
      ],
    ),
    SettingsCategory(
      label: 'Notifications',
      icon: Icons.notifications,
      groups: [
        SettingsGroup(
          label: 'Application Events',
          settings: [
            Setting<AppSettingKeys, int>(
              storageKey: AppSettingKeys.notifyTimeTreshold,
              title: 'Time treshold',
              description:
                  'Only notify about events that are at least x hours old',
              defaultValue: 5,
            ),
            Setting<AppSettingKeys, bool>(
              storageKey: AppSettingKeys.notifyErrorEvents,
              title: 'Error Events',
              description: 'Show notifications for error application events.',
              defaultValue: true,
            ),
            Setting<AppSettingKeys, bool>(
              storageKey: AppSettingKeys.notifyWarningEvents,
              title: 'Warning Events',
              description: 'Show notifications for warning application events.',
              defaultValue: true,
            ),
            Setting<AppSettingKeys, bool>(
              storageKey: AppSettingKeys.notifyInfoEvents,
              title: 'Info Events',
              description: 'Show notifications for info application events.',
              defaultValue: false,
            ),
          ],
        ),
      ],
    )
  ],
);
