
if Code.ensure_loaded?(SweetXml) do
  defmodule ExAws.EC2.Parser do
    import SweetXml, only: [sigil_x: 2]

    def parse({:ok, %{body: xml, status_code: 200} = resp}, :describe_tags) do
      parsed_body =
        xml
        |> SweetXml.xpath(
          ~x"//DescribeTagsResponse",
          tag_set: [
            ~x".//tagSet/item"l,
            key: ~x"./key/text()"s,
            value: ~x"./value/text()"s
          ],
          next_token: ~x"./NextToken/text()"s,
          request_id: ~x"./RequestId/text()"s
        )

      {:ok, Map.put(resp, :body, parsed_body)}
    end

    def parse({:error, {type, http_status_code, %{body: xml}}}, _) do
      parsed_body =
        xml
        |> SweetXml.xpath(
          ~x"//Response",
          errors: [
            ~x".//Error"l,
            type: ~x"./Type/text()"s,
            code: ~x"./Code/text()"s,
            message: ~x"./Message/text()"s,
            detail: ~x"./Detail/text()"s
          ],
          request_id: ~x"./RequestID/text()"s
        )

      {:error, {type, http_status_code, parsed_body}}
    end

    def parse(val, _), do: val
  end
else
  defmodule ExAws.EC2.Parser do
    def parse(val, _), do: val
  end
end
