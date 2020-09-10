package com.pn_x.extjsbridge.compiler;

import com.google.auto.service.AutoService;
import com.pn_x.extjsbridge.annotations.ExtActionVerify;
import com.pn_x.extjsbridge.annotations.ExtAsyncAction;

import java.util.List;
import java.util.Set;

import javax.annotation.processing.Processor;
import javax.annotation.processing.RoundEnvironment;
import javax.annotation.processing.SupportedAnnotationTypes;
import javax.annotation.processing.SupportedSourceVersion;
import javax.lang.model.SourceVersion;
import javax.lang.model.element.Element;
import javax.lang.model.element.ElementKind;
import javax.lang.model.element.ExecutableElement;
import javax.lang.model.element.TypeElement;
import javax.lang.model.element.VariableElement;
import javax.lang.model.type.TypeMirror;
import javax.lang.model.type.TypeVariable;

@AutoService(Processor.class)
@SupportedAnnotationTypes({"com.pn_x.extjsbridge.annotations.ExtAsyncAction"})
@SupportedSourceVersion(SourceVersion.RELEASE_8)
public class ExtAsyncActionProcessor extends BaseProcessor {
    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {
        if (annotations != null && !annotations.isEmpty()) {
            Set<? extends Element> elements = roundEnv.getElementsAnnotatedWith(ExtAsyncAction.class);
            try {
                info("Process ExtAsyncAction start ...");
                this.parseAsyncAction(elements);
            } catch (Exception e) {
                error(e.getMessage());
            }
            return true;
        }
        return false;
    }

    private void parseAsyncAction(Set<? extends Element> elements) {
        if (elements == null || elements.isEmpty()) return;
        for (Element element : elements) {
            if (!(element instanceof ExecutableElement) || element.getKind() != ElementKind.METHOD) {
                error(element.asType().toString() + " @ExtAsyncAction only works for method");
            }

            ExecutableElement executableElement = (ExecutableElement) element;
            TypeElement enclosingElement = (TypeElement) element.getEnclosingElement();

            String methodName = executableElement.getSimpleName().toString();
            ExtAsyncAction asyncAction = element.getAnnotation(ExtAsyncAction.class);
            String[] actions = asyncAction.value();

            if (actions == null || actions.length <= 0) {
                error("ExtAsyncAction is empty for method: " + enclosingElement.toString());
            }

            ExtActionVerify verify = ExtAsyncAction.class.getAnnotation(ExtActionVerify.class);
            if (verify != null) {
                String[] targetParameters = verify.parameters();
                String targetReturnType = verify.returnType();
                List<? extends VariableElement> nowParameters = executableElement.getParameters();
                TypeMirror nowReturnType = executableElement.getReturnType();
                if (nowReturnType instanceof TypeVariable) {
                    TypeVariable typeVariable = (TypeVariable) nowReturnType;
                    nowReturnType = typeVariable.getUpperBound();
                }
//                if (targetParameters.length != nowParameters.size()) {
//                    error(enclosingElement.toString() + "#" + executableElement.toString() + " async parameters should be " + Arrays.toString(targetParameters).replaceAll("\\[", "(").replaceAll("]", ")"));
//                }
//                if (nowParameters.size() > 3) {
//                    error(enclosingElement.toString() + "#" + executableElement.toString() + " async count of parameters should not exceed 3");
//                }
//                if (nowParameters.size() == 3) {
//                    for (int i = 0; i < targetParameters.length; i++) {
//                        String targetParameter = targetParameters[i];
//                        if (targetParameter.equals("java.lang.Object")) {
//                            continue;
//                        }
//                        String nowParameter = nowParameters.get(i).asType().toString();
//                        if (!targetParameter.equals(nowParameter)) {
//                            error(enclosingElement.toString() + "#" + executableElement.toString() + " parameters should be " + Arrays.toString(targetParameters).replaceAll("\\[", "(").replaceAll("]", ")"));
//                        }
//                    }
//                }
                if (!targetReturnType.equals("java.lang.Object") && !targetReturnType.equals(nowReturnType.toString())) {
                    error(enclosingElement.toString() + "#" + executableElement.toString() + " return type should be " + targetReturnType);
                }
            }

        }
    }
}
