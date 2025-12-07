# Cursor Code Review Actions

Коллекция reusable actions для автоматического code review с использованием Cursor Agent.

## Доступные actions

### 1. General Code Review (общий)
**Путь:** `.gitea/actions/cursor-code-review/general`

Универсальный action для code review любых языков программирования.

**Использование:**
```yaml
- name: Run Code Review
  uses: ./.gitea/actions/cursor-code-review/general
  with:
    cursor_api_key: ${{ secrets.CURSOR_API_KEY }}
    model: auto
    gh_token: ${{ secrets.GITHUB_TOKEN }}
    blocking_review: 'false'
```

**Проверяет:**
- Соответствие ТЗ/требованиям PR
- Технические проблемы (универсальные)
- Безопасность
- Производительность
- Логические ошибки

### 2. PHP Code Review (специализированный)
**Путь:** `.gitea/actions/cursor-code-review/php`

Специализированный action для PHP 8.4 проектов с Doctrine ORM, Symfony компонентами и PSR-12.

**Использование:**
```yaml
- name: Run PHP Code Review
  uses: ./.gitea/actions/cursor-code-review/php
  with:
    cursor_api_key: ${{ secrets.CURSOR_API_KEY }}
    model: auto
    gh_token: ${{ secrets.GITHUB_TOKEN }}
    blocking_review: 'false'
```

**Проверяет:**
- Все проверки из General Code Review
- PHP 8.4 специфичные проблемы (strict types, типизация)
- Doctrine ORM (N+1 queries, индексы, транзакции)
- Symfony компоненты (DI, Validator, Serializer)
- PSR-12 стандарты кодирования
- PHPDoc документация

## Входные параметры

Оба action используют одинаковые входные параметры:

| Параметр | Описание | Обязательный | По умолчанию |
|----------|----------|--------------|--------------|
| `cursor_api_key` | API ключ для Cursor | Да | - |
| `model` | Модель для использования | Нет | `auto` |
| `gh_token` | Токен для GitHub/Gitea API | Да | - |
| `blocking_review` | Включить блокирующий review. Если `true`, workflow завершится с ошибкой при обнаружении критических проблем (🚨 Critical или 🔒 Security). | Нет | `false` |
| `custom_prompt` | Кастомный промпт для переопределения инструкций по code review. | Нет | `''` (пустая строка) |

## Выбор action

- **Используйте `general`** для проектов на любых языках (JavaScript, Python, Go, Rust и т.д.)
- **Используйте `php`** для PHP 8.4 проектов с Doctrine ORM и Symfony

## Структура

```
.gitea/actions/cursor-code-review/
├── general/
│   ├── action.yml          # Общий action для любых языков
│   └── README.md           # Документация общего action
├── php/
│   ├── action.yml          # PHP-специфичный action
│   └── README.md           # Документация PHP action
└── README.md               # Этот файл
```

## Примеры workflow

### Для PHP проекта

```yaml
name: PHP Code Review

on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]

permissions:
  pull-requests: write
  contents: read
  issues: write

jobs:
  code-review:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    if: github.event.pull_request.draft == false
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          ref: ${{ github.event.pull_request.head.sha }}

      - name: Run PHP Code Review
        uses: ./.gitea/actions/cursor-code-review/php
        with:
          cursor_api_key: ${{ secrets.CURSOR_API_KEY }}
          model: auto
          gh_token: ${{ secrets.GITHUB_TOKEN }}
          blocking_review: ${{ vars.BLOCKING_REVIEW != '' && vars.BLOCKING_REVIEW || 'false' }}
```

### Для проекта на другом языке

```yaml
name: Code Review

on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]

permissions:
  pull-requests: write
  contents: read
  issues: write

jobs:
  code-review:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    if: github.event.pull_request.draft == false
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          ref: ${{ github.event.pull_request.head.sha }}

      - name: Run Code Review
        uses: ./.gitea/actions/cursor-code-review/general
        with:
          cursor_api_key: ${{ secrets.CURSOR_API_KEY }}
          model: auto
          gh_token: ${{ secrets.GITHUB_TOKEN }}
          blocking_review: 'false'
```
