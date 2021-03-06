# code pal for ABAP

[code pal for ABAP](../../README.md) > [Documentation](../check_documentation.md) > [Chain Declaration Usage](chain-declaration-usage.md)

## Chain Declaration Usage

### What is the Intent of the Check?

The "Chain Declaration Usage" check verifies the usage of the chain up-front declarations.

### How to solve the issue?

Change the chain up-front declarations to inline declarations.

### What to do in case of exception?

You can suppress Code Inspector findings generated by this check using the pseudo comment `"#EC CHAIN_DECL_USAG`.  
The pseudo comment has to be placed after the `DATA:` statement.

```abap
  DATA: "#EC CHAIN_DECL_USAG
    string TYPE string,
    json TYPE REF TO cl_abap_json,
    client LIKE sy-mandt.
```

### Example

Before the check:

```abap
  DATA:
    string TYPE string,
    json TYPE REF TO cl_abap_json,
    client LIKE sy-mandt.
```

After the check:

```abap
  DATA string TYPE string.
  DATA json TYPE REF TO cl_abap_json.
  DATA client LIKE sy-mandt.
```

### Further Readings & Knowledge

* [ABAP Styleguides on Clean Code](https://github.com/SAP/styleguides/blob/master/clean-abap/CleanABAP.md#do-not-chain-up-front-declarations)
