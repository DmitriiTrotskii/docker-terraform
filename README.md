# Terraform

##  Описание

Hashicorp блокирует доступ к своим репозиториям для РФ сегмента. 

```shell
terraform init
```
```
Error: Failed to query available provider packages

Could not retrieve the list of available versions for provider integrations/github: could not connect to registry.terraform.io: Failed to request discovery document: 403 Forbidden
```

Доступ к исходникам на github не блокируется. Данный образ собирает из исходников сам модуль terraform и некоторые провайдеры для него.

Все пути провайдеров сохраняются, так что для их использования достаточно добавить ```local/``` при указании провайдера.

Со всем провайдерами обаз получается довольно большой, около 1GB.

---

| [Terraform](https://github.com/hashicorp/terraform/)                            | v1.2.3   | 84M  |
| :------------------------------------------------------------------------------ | :------: | ---: |
| [vSphere](https://github.com/hashicorp/terraform-provider-vsphere/)             | v2.2.0   | 36M  |
| [Github](https://github.com/integrations/terraform-provider-github/)            | v4.26.1  | 26M  |
| [Gitlab](https://github.com/gitlabhq/terraform-provider-gitlab)                 | v3.15.1  | 24M  |
| [YandexCloud](https://github.com/yandex-cloud/terraform-provider-yandex)        | v0.75.0  | 63M  |
| [DigitalOcean](https://github.com/digitalocean/terraform-provider-digitalocean) | v2.21.0  | 27M  |
| [AWS](https://github.com/hashicorp/terraform-provider-aws/)                     | v.4.20.1 | 337M |
| [Local](https://github.com/hashicorp/terraform-provider-local/)                 | v.2.2.3  | 19M  |
| [Random](https://github.com/hashicorp/terraform-provider-random/)               | v3.3.2   | 19M  |

---

## Использование

1.  Колинировать репозиторий

```shell
git clone https://github.com/DmitriiTrotskii/docker-terraform.git && cd docker-terraform
```

2.  Изменить версии на актуальные / удалить не нужные провайдеры

```Dockerfile
ARG TF_VERSION=1.2.3
ARG TF_VSPHERE_VER=2.2.0
ARG TF_GITHUB_VER=4.26.1
ARG TF_GITLAB_VER=3.15.1
ARG TF_YC_VER=0.75.0
ARG TF_DO_VER=2.21.0
ARG TF_AWS_VER=4.20.1
ARG TF_LOCAL_VER=2.2.3
ARG TF_RANDOM_VER=3.3.2
```

Удалить проще всего из итогового образа, провайдер все равно будет компилироваться но в итоговый образ не попадет, что уменьшит его вес

Так, например, в итоговый образ не попадет самый тяжеловесный провайдер AWS:
```Dockerfile
COPY --from=builder /tmp/bin/${TF_VSPHERE}_${TF_VSPHERE_VER} ${TF_PLUGINS_DIR}/hashicorp/vsphere/${TF_VSPHERE_VER}/${ARCH}/
COPY --from=builder /tmp/bin/${TF_GITHUB}_${TF_GITHUB_VER} ${TF_PLUGINS_DIR}/integrations/github/${TF_GITHUB_VER}/${ARCH}/
COPY --from=builder /tmp/bin/${TF_GITLAB}_${TF_GITLAB_VER} ${TF_PLUGINS_DIR}/gitlabhq/gitlab/${TF_GITLAB_VER}/${ARCH}/
COPY --from=builder /tmp/bin/${TF_YC}_${TF_YC_VER} ${TF_PLUGINS_DIR}/yandex-cloud/yandex/${TF_YC_VER}/${ARCH}/
COPY --from=builder /tmp/bin/${TF_DO}_${TF_DO_VER} ${TF_PLUGINS_DIR}/digitalocean/digitalocean/${TF_DO_VER}/${ARCH}/
#   COPY --from=builder /tmp/bin/${TF_AWS}_${TF_AWS_VER} ${TF_PLUGINS_DIR}/hashicorp/aws/${TF_AWS_VER}/${ARCH}/
COPY --from=builder /tmp/bin/${TF_LOCAL}_${TF_LOCAL_VER} ${TF_PLUGINS_DIR}/hashicorp/local/${TF_LOCAL_VER}/${ARCH}/
COPY --from=builder /tmp/bin/${TF_RANDOM}_${TF_RANDOM_VER} ${TF_PLUGINS_DIR}/hashicorp/random/${TF_RANDOM_VER}/${ARCH}/
```

3. Собрать образ

```shell
docker build . -t container_name
```

## Пути для провайдеров

```
terraform {
  required_providers {
    <PROVIDER_NAME> = {
        source = "local/<PATH> "
        version = ">= <VERSION>"
    }
  }
}
```

| registry.terraform.io     | LOCAL                             |
|:------------------------- | :-------------------------------- |
| integrations/github       | `local/`integrations/github       |
| digitalocean/digitalocean | `local/`digitalocean/digitalocean |
| gitlabhq/gitlab           | `local/`gitlabhq/gitlab           |
| hashicorp/aws             | `local/`hashicorp/aws             |
| hashicorp/local           | `local/`hashicorp/local           |
| hashicorp/random          | `local/`hashicorp/random          |
| hashicorp/vsphere         | `local/`hashicorp/vsphere         |
| yandex-cloud/yandex       | `local/`yandex-cloud/yandex       |







