# Workflows

CI/CD actions и автоматизация для микросервисов LO Backend.

## Структура

```
workflows/
├── cursor-code-review/       # Автоматический code review
│   ├── general/              # Универсальный action (все языки)
│   │   └── action.yml
│   └── php/                  # PHP-специфичный action (PHP 8.4, Doctrine, Symfony)
│       └── action.yml
│
└── go-actions/               # CI для Go-сервисов
    ├── prepare/              # Подготовка Go-окружения
    │   └── action.yml
    └── build-image/          # Сборка Docker-образа
        └── action.yml
```

---

## cursor-code-review

Reusable Gitea/GitHub actions для автоматического code review с Cursor Agent.

### Доступные actions

| Action | Путь | Описание |
|--------|------|----------|
| General | `cursor-code-review/general` | Универсальный review: ТЗ, безопасность, производительность, логические ошибки |
| PHP | `cursor-code-review/php` | PHP 8.4: strict types, Doctrine ORM (N+1, индексы), Symfony, PSR-12, PHPDoc |

### Параметры

| Параметр | Обязательный | Описание |
|----------|:---:|----------|
| `cursor_api_key` | да | API-ключ Cursor |
| `model` | нет | Модель (default: `auto`) |
| `gh_token` | да | Токен GitHub/Gitea API |
| `blocking_review` | нет | При `true` — workflow падает на critical/security (default: `false`) |
| `custom_prompt` | нет | Кастомный промпт |

### Пример использования

```yaml
- name: Run Code Review
  uses: ./.gitea/actions/cursor-code-review/general
  with:
    cursor_api_key: ${{ secrets.CURSOR_API_KEY }}
    model: auto
    gh_token: ${{ secrets.GITHUB_TOKEN }}
    blocking_review: 'false'
```

Подробнее: [cursor-code-review/README.md](cursor-code-review/README.md)

---

## go-actions

CI actions для Go-микросервисов.

| Action | Путь | Описание |
|--------|------|----------|
| prepare | `go-actions/prepare` | Подготовка Go-окружения (установка Go, настройка GOPRIVATE, кеш) |
| build-image | `go-actions/build-image` | Сборка и публикация Docker-образа |
