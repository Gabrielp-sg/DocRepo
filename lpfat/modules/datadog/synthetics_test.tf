resource "datadog_synthetics_test" "test_ssl" {
  type    = "api"
  subtype = "ssl"
  name    = format("0072-wkl-lpbr-apps - Test SSL on %s", var.url)
  message = format("The certificate in %s will expire in less than 30 days Notify: @opsgenie-opsgenie-prod", var.url)
  status  = "live"

  request_definition {
    host = var.url
    port = 443
  }

  assertion {
    type     = "certificate"
    operator = "isInMoreThan"
    target   = 30
  }

  locations = ["aws:eu-west-1"]
  options_list {
    tick_every         = 86400
    accept_self_signed = true

    ci {
      execution_rule = "non_blocking"
    }
  }

  tags = local.dd_tags
}

resource "datadog_synthetics_test" "test_portal_gestor" {
  type    = "api"
  subtype = "http"
  name    = format("0072-wkl-lpbr-apps - Test access to %s", var.url)
  message = format("I was unable to access %s Notify: @opsgenie-opsgenie-prod", var.url)
  status  = "live"

  request_definition {
    method = "GET"
    url    = format("https://%s", var.url)
  }

  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }

  locations = ["aws:eu-west-1"]

  options_list {
    tick_every = 86400

    retry {
      count    = 2
      interval = 300
    }

    monitor_options {
      renotify_interval = 120
    }
    ci {
      execution_rule = "non_blocking"
    }
  }

  tags = local.dd_tags
}

resource "datadog_synthetics_test" "test_portal_gestor_sydle" {
  count = var.environment == "development" ? 0 : 1

  type    = "api"
  subtype = "http"
  name    = "0072-wkl-lpbr-apps - Test access to https://portal-leaseplan.sydle.com"
  message = "I was unable to access https://portal-leaseplan.sydle.com Notify: @opsgenie-opsgenie-prod"
  status  = "live"

  request_definition {
    method = "GET"
    url    = "https://portal-leaseplan.sydle.com"
  }

  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }

  locations = ["aws:eu-west-1"]

  options_list {
    tick_every = 1800

    retry {
      count    = 2
      interval = 300
    }

    monitor_options {
      renotify_interval = 120
    }

    ci {
      execution_rule = "non_blocking"
    }
  }

  tags = local.dd_tags
}
