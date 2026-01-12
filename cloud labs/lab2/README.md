# Отчёт по анализу структуры потребления облачных сервисов Azure

### Работа была выполнена нашей командой вместе с Кретовым Иваном и Мироновым Иваном

В ходе выполнения работы был обработан биллинг-файл поставщика облачных услуг Microsoft Azure, содержащий данные об использовании сервисов без указания финансовых показателей. Основное внимание уделялось анализу полей: Meter Category, Meter Sub-Category, Meter Name, Consumed Service.

На основе этих данных была проведена категоризация потребляемых сервисов согласно иерархической модели:

1. **IT Tower** — высокоуровневая категория (например, Cloud Services, Compute, Networking, Database).
2. **Service Family** — группа сервисов (например, Security and Identity, Management Tools, Analytics).
3. **Service Type** — конкретный сервис (например, Azure Key Vault, Azure Automation, Azure Synapse Analytics).
4. **Service Sub Type** — подтип услуги (например, Hardware Security Module, Flow Licensing, Warehouse Usage).
5. **Service Usage Type** — тип потребления (например, HSM Key Operations, Per Flow Plan, DWU Hours).

В результате анализа выявлены следующие ключевые группы сервисов с возможными аналогами в экосистеме российских облачных платформ:

- **Управление и мониторинг** (Azure Automation, Azure Monitor Logs, Application Insights) — аналоги: VK Cloud Monitoring, Yandex Cloud Monitoring, Selectel Cloud Logging.
- **Безопасность и идентификация** (Azure Key Vault, Azure Backup, Azure Site Recovery) — аналоги: VK Cloud KMS, Yandex Cloud Lockbox, SberCloud Security Center.
- **Аналитика и данные** (Azure Synapse Analytics, Power BI, Power BI Embedded) — аналоги: Yandex DataSphere, VK Cloud Data Platform, Arenadata.
- **Сетевые сервисы** (Azure Bastion, Azure Firewall, Azure API Management) — аналоги: Yandex Cloud VPC, Selectel Cloud Networking, MCS Firewall.
- **Вычисления и контейнеры** (Azure Virtual Machines, Azure App Service) — аналоги: Yandex Compute Cloud, VK Cloud Servers, SberCloud Elastic Compute.
- **Мобильные и push-уведомления** (Visual Studio App Center, Notification Hubs) — аналоги: Yandex Cloud Mobile, VK Cloud Push.
- **Управление конфигурацией** (App Configuration) — аналоги: Yandex Cloud Lockbox, VK Cloud Config.

В результате структуризации данные приведены в аналитический формат, который позволяет чётко определять принадлежность затрат к категориям, агрегировать данные на различных уровнях и проводить управленческий анализ расходов и оптимизировать потребление облачных ресурсов.

Таблица готова для дальнейшего использования в системах мониторинга затрат, планирования бюджета и анализа эффективности использования облачной инфраструктуры.