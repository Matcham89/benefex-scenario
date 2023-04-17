# Runbook-2

To add an additional data drive to the existing vm configuration, access `benefex-infrastructure/modules/gce/main.tf`

The `google_compute_disk` resource is used in this module

Create an additional drive for each vm by adding the below configuration

Disk-03
```bash
resource "google_compute_disk" "win_add_disk_03" {
  name = "${var.vm_disk_name}-${substr(var.region, 0, 2)}-03"
  type = var.vm_disk_type
  zone = "${var.region}-a"
  size = var.disk_size_gb
}
```

Disk-04
```bash
resource "google_compute_disk" "win_add_disk_04" {
  name = "${var.vm_disk_name}-${substr(var.region, 0, 2)}-04"
  type = var.vm_disk_type
  zone = "${var.region}-a"
  size = var.disk_size_gb
}
```

Attach the newly added drive to each vm by using the `attached_disk` block

This can be placed under the current attached disk

```bash
 attached_disk {
    source      = google_compute_disk.win_add_disk_03.id
    device_name = google_compute_disk.win_add_disk_03.name
  }
```


```bash
 attached_disk {
    source      = google_compute_disk.win_add_disk_04.id
    device_name = google_compute_disk.win_add_disk_04.name
  }
```


Repeat the terraform deployment steps

```bash
terraform init -backend-config="prefix=dev"
```

```bash
terraform plan -var-file=dev.tfvars -out plan.yaml
```

Review the plan, ensure you are happy with the predicted deployment

```bash
terraform apply ./plan.yaml
```

```bash
Apply complete!
```
