# Day 02 — Issues & Fixes (Terraform Backend, OIDC, Storage Hardening)

This log consolidates failures, root causes, and fixes from Day 02. Each item uses a uniform structure: **Symptom**, **Root cause**, **Fix**, **Outcome**.

---

## 1) Federated Credential name invalid
**Symptom:** Creation of Federated Credential failed.  
**Root cause:** Name contained hidden RTL / non-ASCII characters.  
**Fix:** Use plain ASCII name only: `gh-main-oidc-day02`.  
**Outcome:** Credential created successfully and visible in the App Registration.

---

## 2) Audience seemingly missing
**Symptom:** Audience field appeared empty in the UI.  
**Root cause:** Azure defaults the audience to `api://AzureADTokenExchange`.  
**Fix:** No change required.  
**Outcome:** Token exchange works with the default audience.

---

## 3) Storage protection set incorrectly
**Symptom:** JSON policy error on blob management policy.  
**Root cause:** Policy shape did not match the schema.  
**Fix:** Enable built-in protection settings instead of pushing malformed JSON:
```bash
az storage account blob-service-properties update \
  --account-name stday02tfstatecli \
  --resource-group rg-day02-backend-cli \
  --enable-versioning true \
  --enable-delete-retention true --delete-retention-days 30 \
  --enable-container-delete-retention true --container-delete-retention-days 30
Outcome: Versioning and soft delete are enforced at the service layer.

4) azure/login → “No subscriptions found”
Symptom: GitHub Action could not see any subscriptions.
Root cause: OIDC app had no role assignment on the subscription.
Fix: Grant at least Reader on the subscription scope:

bash
Copy code
az role assignment create \
  --role "Reader" \
  --assignee <AppId> \
  --scope /subscriptions/<SubscriptionId>
Outcome: Action can enumerate the subscription and proceed.

5) Duplicate provider configuration in Terraform
Symptom: terraform init failed with duplicate azurerm provider block.
Root cause: Multiple provider "azurerm" blocks across files.
Fix: Keep the provider in a single file; remove the duplicate from backend-cli.tf.
Outcome: terraform init completes cleanly.

6) Terraform auth error: “Authenticating using the Azure CLI is only supported as a User”
Symptom: init/plan failed in GitHub Actions.
Root cause: Provider attempted to auth via Azure CLI user context.
Fix: Use OIDC variables in workflow env:

yaml
Copy code
env:
  ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
  ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
  ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
  ARM_USE_OIDC: true
Outcome: Provider authenticates via OIDC as the Service Principal.

7) Microsoft.ManagedIdentity not registered
Symptom: terraform plan failed when creating a User Assigned Managed Identity.
Root cause: Resource provider not registered on the subscription.
Fix:

bash
Copy code
az provider register --namespace Microsoft.ManagedIdentity
Add a wait step in the workflow until state becomes Registered.
Also set in the provider:

hcl
Copy code
skip_provider_registration = true
Outcome: Identity resources provision successfully without auto-registering as a user.

8) Local Git issues
Symptom: fatal: not a git repository and identity prompts.
Root cause: Commands executed outside the repo + missing Git identity.
Fix:

bash
Copy code
git config --global user.name "Ehab Saad"
git config --global user.email "ehab.saad100985@gmail.com"
Ensure commands run inside the cloned repo directory.
Outcome: Commits and pushes work as expected.

9) Enforce Azure AD–only access for Storage
Symptom/Goal: Prevent use of Shared Key and public access.
Fix:

bash
Copy code
az storage account update \
  --name stday02tfstatecli \
  --resource-group rg-day02-backend-cli \
  --allow-blob-public-access false \
  --allow-shared-key-access false
Outcome: Only Azure AD–based auth paths remain.

10) Secure Terraform Backend
Symptom/Rule: Backend must not rely on storage access keys.
Fix/Setting:

hcl
Copy code
use_azuread_auth = true
Outcome: Backend uses Azure AD / OIDC only.

Final state
Backend hardened.

OIDC path validated end-to-end.

terraform init and plan succeed consistently.
