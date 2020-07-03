# About

Repository ini berisi PHP dan Terraform script untuk membangun API menggunakan Lambda.

Untuk panduan lengkap silahkan merujuk pada artikel TeknoCerdas.com berikut.

- [Serverless PHP: Membuat API dengan AWS Lambda dan Runtime Bref](https://teknocerdas.com/programming/serverless-php-membuat-api-dengan-aws-lambda-dan-runtime-bref/)

## How to Run

Pastikan anda memiliki AWS account dengan privilege Administrator agar tidak terjadi masalah ketika menjalankan Terraform.

```
$ export AWS_PROFILE=YOUR_PROFILE AWS_DEFAULT_REGION=YOUR_REGION
```

Build API script terlebih dahulu.

```
$ bash build.sh
```

Masuk pada directory `terraform/` dan mulai jalankan init dan apply untuk membuat resources yang diperlukan.

```
$ terraform init
$ terraform apply
```

```
...
Outputs:

api = {
  "end_point" = "GET https://d768z7u49a.execute-api.us-east-1.amazonaws.com/myip"
}
```

## License

Repository ini dilensiskan dibawah naungan [MIT License](https://opensource.org/licenses/MIT).
