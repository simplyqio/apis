---
sidebar_position: 1
title: Overview
---

An environment is an isolated resource space. This means that each environment is unique and all resources created in that environment will not be shared with other environments. This is useful for isolating resources for different purposes, such as development, testing and production.

An account can have multiple environments - limit based on your subscription plan. Each environment has its own API key, which is used to authenticate requests to the API.

Any identifiers (such as application UID) are unique within an environment. This means that you can have an application with the same UID in different environments.

Environments cannot be programmatically created, updated or deleted. You can [create an environment by following our guide](./create-environment).

## API Key

Each environment has its own API key, which is used to authenticate requests to the API. You can find the API key by visiting [your dashboard](https://app.simplyq.io/apikeys).

To rotate the API key, you can [follow our guide](./rotate-api-key).

## Quota

Each environment shared the same account quota. This means that the total number of resources created in all environments cannot exceed the quota of the account.
