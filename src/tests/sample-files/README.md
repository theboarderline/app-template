
## API System Level Tests

#### Requirements
- Golang 1.20

#### Initialize environment
```
go get
```

#### Run tests
```
go test
```

### Testing Tips/Guidelines

- Tests are run against live environments (e.g. [Dev GraphQL API](https://dev.boatload.us/api/))
- Specify which domain to test against with `APP_URL` in .env file (e.g. `APP_URL=https://dev.boatload.us`)
