# rclone-getting-started
Materials for started with copying data between clouds using rclone


1. Install `rclone`
```
brew install rclone
```
2. Setup a service principal in Azure 
```
az ad sp create-for-rbac --name konradrclonesp \
                         --role "Storage Blob Data Contributor" \
                         --scopes /subscriptions/5ddf05c0-b972-44ca-b90a-3e49b5de80dd/resourceGroups/konrad-burnik-sandbox/providers/Microsoft.Storage/storageAccounts/stkburniksparktryout

{
"appId": "fdbda3ff-9e75-4a12-9ce0-bb4a6dc3cb6d",
"displayName": "konradrclonesp",
"password": "<REDACTED>",
"tenant": "3d4d17ea-1ae4-4705-947e-51369c5a5f79"
}
```
3. rclone config
    - create a config for azure named `azure`
    - enter the information for `client_id`, `client_secret` and `tenant_id`

The storage account structure:

```
storage account: stkburniksparktryout
   container: fskburniksparktryout
     folder: test
```

Example command of using sync
```
rclone sync -v azure:fskburniksparktryout/test azure:fskburniksparktryout/test2

2025/03/21 13:37:33 INFO  : banking.csv: Copied (server-side copy)
2025/03/21 13:37:33 INFO  :
Transferred:   	  655.224 KiB / 655.224 KiB, 100%, 0 B/s, ETA -
Transferred:            1 / 1, 100%
Server Side Copies:     1 @ 655.224 KiB
Elapsed time:         0.1s
```

## Copying blobs between clouds

Create a config for GCP
```
gcloud iam service-accounts create konradrclonesa --description="Service account for testing rclone. Can be deleted anytime" --display-name="Konrad's Test Rclone Service Account"
Created service account [konradrclonesa].
```

Get the service account file
```
gcloud iam service-accounts keys create service_account.json --iam-account=konradrclonesa@konrad-burnik-sndbx-n.iam.gserviceaccount.com
```

```
rclone config
```

```
Configuration complete.
Options:
- type: google cloud storage
- client_id: konradrclonesa
- client_secret: 1768aa10fa12288ff16e0f6c8b8bfd8747123b61
- project_number: 679851910909
- user_project: konrad-burnik-playground
- service_account_file: ~/service_account.json
- location: europe-west3
- env_auth: true
Keep this "gcp" remote?
y) Yes this is OK (default)
e) Edit this remote
d) Delete this remote
```


```
gcloud iam service-accounts add-iam-policy-binding  \
    --member=user:konrad.burnik@xebia.com --role=roles/storage.objectCreator
```

```
gcloud iam service-accounts add-iam-policy-binding konradrclonesa@konrad-burnik-playground.iam.gserviceaccount.com  \
    --member=user:konrad.burnik@xebia.com --role=roles/owner --project konrad-burnik-playground
Updated IAM policy for serviceAccount [konradrclonesa@konrad-burnik-playground.iam.gserviceaccount.com].
bindings:
- members:
  - user:konrad.burnik@xebia.com
  role: roles/owner
etag: BwYw25SHsXU=
version: 1
```

```
gcloud projects add-iam-policy-binding konrad-burnik-playground \
            --member='serviceAccount:konradrclonesa@konrad-burnik-playground.iam.gserviceaccount.com' \
            --role='roles/owner'
```


```
2025/03/21 16:15:52 NOTICE: Failed to copy: googleapi: Error 400: Cannot insert legacy ACL for an object when uniform bucket-level access is enabled. Read more at https://cloud.google.com/storage/docs/uniform-bucket-level-access, invalid
```

Just recreate the bucket with fine-grained access.

```
rclone copy -v azure:fskburniksparktryout/test testgcp:xebia-konradburnik-test-bucket/test2
Enter configuration password:
password:
2025/03/21 16:19:39 INFO  : banking.csv: Copied (new)
2025/03/21 16:19:39 INFO  :
Transferred:   	  655.224 KiB / 655.224 KiB, 100%, 0 B/s, ETA -
Transferred:            1 / 1, 100%
Elapsed time:         0.4s
```

```
rclone copy -v testgcp:xebia-konradburnik-test-bucket/test2 azure:fskburniksparktryout/test2
Enter configuration password:
password:
2025/03/21 16:21:39 INFO  : banking.csv: Copied (new)
2025/03/21 16:21:39 INFO  :
Transferred:   	  655.224 KiB / 655.224 KiB, 100%, 0 B/s, ETA -
Transferred:            1 / 1, 100%
Elapsed time:         0.2s
```


