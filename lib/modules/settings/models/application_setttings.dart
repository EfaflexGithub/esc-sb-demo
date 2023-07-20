import 'package:efa_smartconnect_modbus_demo/modules/settings/models/setting_types.dart';
import 'package:flutter/material.dart';

enum ApplicationSettingKeys {
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
}

final applicationSettings = ApplicationSettings(
  categories: [
    SettingsCategory(
      label: 'General',
      icon: Icons.apps,
      groups: [
        SettingsGroup(label: 'Appereance', settings: [
          Setting(
            storageKey: ApplicationSettingKeys.appDarkMode,
            title: 'Dark Mode',
            defaultValue: false,
          )
        ]),
        SettingsGroup(
          label: 'Event Highlighting',
          settings: [
            Setting(
              storageKey: ApplicationSettingKeys.eventHighlightingTime,
              title: 'Highlight by Hours',
              description:
                  'Events that happended during the last x hours will be highlighted.',
              defaultValue: 72,
            ),
            Setting(
              storageKey: ApplicationSettingKeys.eventHighlightingCycles,
              title: 'Hightlight by Cycles',
              description:
                  'Events that happended during the last x cycles will be highlighted.',
              defaultValue: 20,
            ),
          ],
        ),
        SettingsGroup(
          label: 'User Applications',
          settings: [
            Setting(
              storageKey: ApplicationSettingKeys.showUnknownUserApplications,
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
            Setting(
              storageKey: ApplicationSettingKeys.defaultModbusTcpHostAddress,
              title: 'Host address',
              defaultValue: '127.0.0.1',
            ),
            Setting(
              storageKey: ApplicationSettingKeys.defaultModbusTcpPort,
              title: 'Port',
              defaultValue: 502,
            ),
            Setting(
              storageKey: ApplicationSettingKeys.defaultModbusTcpTimeout,
              title: 'Timeout',
              defaultValue: 1000,
            ),
            Setting(
              storageKey: ApplicationSettingKeys.defaultModbusTcpRetryCount,
              title: 'Refresh rate',
              defaultValue: 1000,
            ),
            Setting(
              storageKey: ApplicationSettingKeys.defaultModbusTcpRefreshRate,
              title: 'License key',
              defaultValue: 'J6LC5-ALT3Q-7HMAB-YZ3GR-MPO7Z-CN33E',
            )
          ],
        ),
      ],
    )
  ],
);
