<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# MessageContextMenu

A Flutter package that provides customizable message context menus with emoji reactions. This package allows you to add iOS-style long-press context menus to message bubbles or other widgets, with support for both actions and emoji reactions.

## Features

- iOS-style and Material Design context menus
- Emoji reaction panel
- Customizable actions with icons and labels
- Automatic positioning and scaling based on screen space
- Manual or automatic alignment control
- Smooth animations
- RTL support

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  message_context_menu: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

Import the package:

```dart
import 'package:message_context_menu/message_context_menu.dart';
```

Wrap your message bubbles with `MessageContextMenu`:

```dart
MessageContextMenu(
  tag: 'unique-message-id', // Used for Hero animation
  // Optional: Control menu alignment manually
  // If not provided, alignment is calculated automatically
  alignLeft: message.isMe ? false : true, 
  actions: [
    MessageAction(
      icon: Icons.reply,
      label: 'Reply',
      onPressed: () {
        // Handle reply action
      },
    ),
    MessageAction(
      icon: Icons.copy,
      label: 'Copy',
      onPressed: () {
        // Handle copy action
      },
    ),
    MessageAction(
      icon: Icons.delete_outline,
      label: 'Delete',
      onPressed: () {
        // Handle delete action
      },
      isDestructive: true, // Shows in red
    ),
  ],
  reactions: [
    EmojiReaction(
      emoji: '😀',
      onPressed: () {
        // Handle reaction
      },
    ),
    EmojiReaction(
      emoji: '❤️',
      onPressed: () {
        // Handle reaction
      },
    ),
    // Add more reactions as needed
  ],
  child: YourMessageBubble(), // Your existing message bubble widget
)
```

## Controlling Menu Alignment

By default, the menu's alignment (left or right) is determined automatically based on the position of the widget on screen. 

However, you can manually control this by setting the `alignLeft` parameter:

```dart
// For messages from me (usually on the right side)
MessageContextMenu(
  alignLeft: false, // Menu will be right-aligned
  ...
)

// For messages from others (usually on the left side)
MessageContextMenu(
  alignLeft: true, // Menu will be left-aligned
  ...
)
```

This allows consistent alignment based on your requirements, regardless of screen position.

## Example

See the `example` directory for a complete chat app example using this package.

## Customization

### MessageAction

The `MessageAction` class accepts the following parameters:

- `icon` (required): The icon to display
- `label` (required): The text label 
- `onPressed` (required): Callback when the action is pressed
- `isDestructive` (optional): If true, displays in red (for delete actions)
- `color` (optional): Custom color for the action

### EmojiReaction

The `EmojiReaction` class accepts:

- `emoji` (required): The emoji string to display
- `onPressed` (required): Callback when the reaction is pressed
- `isSelected` (optional): Whether the reaction is already selected

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
