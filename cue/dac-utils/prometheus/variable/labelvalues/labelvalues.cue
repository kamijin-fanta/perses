// Copyright 2024 The Perses Authors
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package labelvalues

import (
	"strings"
	labelValuesVar "github.com/perses/perses/cue/schemas/variables/prometheus-label-values:model"
	labelNamesVar "github.com/perses/perses/cue/schemas/variables/prometheus-label-names:model"
	listVarBuilder "github.com/perses/perses/cue/dac-utils/variable/list"
	v1Variable "github.com/perses/perses/cue/model/api/v1/variable"
)

_kind=#kind: listVarBuilder.#kind & "ListVariable"
_name=#name: listVarBuilder.#name
_display=#display?: v1Variable.#Display & {
	hidden: bool | *false
}
#dependencies: [...{...}]
_allowAllValue=#allowAllValue: listVarBuilder.#allowAllValue
_allowMultiple=#allowMultiple: listVarBuilder.#allowMultiple
#datasourceName:               listVarBuilder.#datasourceName
#pluginKind:                   listVarBuilder.#pluginKind & labelValuesVar.kind
#metric:                       string
#label:                        string | *#name

// TODO support label arg if provided like ""\(d.label)=\"$\(d.name)\"""
filter: strings.Join(
	[for d in #dependencies {
		[// switch
			if d.#pluginKind == _|_ {"\(d.#name)=\"$\(d.#name)\""},
			if d.#pluginKind != _|_ if d.#pluginKind != labelNamesVar.kind {"\(d.#name)=\"$\(d.#name)\""},
		][0]
	}],
	",",
	)

queryExpr: #metric + "{" + filter + "}"

variable: {listVarBuilder & {#kind: _kind, #name: _name, #display: _display, #allowAllValue: _allowAllValue, #allowMultiple: _allowMultiple}}.variable & {
	spec: {
		plugin: labelValuesVar & {
			spec: {
				datasource: {
					kind: "PrometheusDatasource"
					name: #datasourceName
				}
				labelName: #label
				matchers: [queryExpr]
			}
		}
	}
}